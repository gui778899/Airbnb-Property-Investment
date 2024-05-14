import os.path

from django.shortcuts import render
import pandas as pd
import xgboost
import json
from django.http import JsonResponse

from django.views.decorators.csrf import csrf_exempt

# Create your views here.
CORRECT_FEATURE_ORDER = ['host_response_time',
 'host_response_rate',
 'host_acceptance_rate',
 'host_is_superhost',
 'host_neighbourhood',
 'host_listings_count',
 'host_total_listings_count',
 'host_has_profile_pic',
 'host_identity_verified',
 'neighbourhood_cleansed',
 'latitude',
 'longitude',
 'property_type',
 'room_type',
 'accommodates',
 'bedrooms',
 'beds',
 'price',
 'minimum_nights',
 'maximum_nights',
 'minimum_minimum_nights',
 'maximum_minimum_nights',
 'minimum_maximum_nights',
 'maximum_maximum_nights',
 'minimum_nights_avg_ntm',
 'maximum_nights_avg_ntm',
 'has_availability',
 'number_of_reviews',
 'number_of_reviews_ltm',
 'number_of_reviews_l30d',
 'review_scores_rating',
 'review_scores_accuracy',
 'review_scores_cleanliness',
 'review_scores_checkin',
 'review_scores_communication',
 'review_scores_location',
 'review_scores_value',
 'instant_bookable',
 'calculated_host_listings_count',
 'calculated_host_listings_count_entire_homes',
 'calculated_host_listings_count_private_rooms',
 'calculated_host_listings_count_shared_rooms',
 'bathrooms_count',
 'private_bath',
 'shared_bath',
 'half_bath',
 'price_estimate',
 'amenity_count',
 'bed_count_1',
 'bed_count_2',
 'bed_count_3',
 'bed_count_4',
 'bed_count_5_+',
 'bedroom_count_1',
 'bedroom_count_2',
 'bedroom_count_3',
 'bedroom_count_4',
 'bedroom_count_5',
 'bedroom_count_6',
 'bedroom_count_7_+',
 'listing_count1',
 'listing_count2',
 'listing_count3',
 'listing_count4',
 'listing_count5',
 'listing_count_6_+',
 'owner_in_neighbourhood']

categorical_features = ["host_response_time", "host_is_superhost", "host_neighbourhood", "host_has_profile_pic", "host_identity_verified", "neighbourhood_cleansed",
                        "room_type", "property_type"]

WORK_TO_RESPONSE_TIME_DICO = {
    4:"within an hour",
    3:"within a few hours",
    2:"within a day ",
    1:"a few days or more",
}

WORK_TO_REVIEW_DICO = {
    4:5,
    3:5,
    2:4,
    1:3,
}

direct_copy_cols = [
    "host_neighbourhood", 'neighbourhood_cleansed', 'latitude', 'longitude',
    'property_type', 'room_type', 'accommodates', 'bedrooms', 'beds', 'bathrooms_count',
       'private_bath', 'shared_bath', 'half_bath', 'price_estimate',
       'amenity_count',
]

nights_col = [
        'minimum_nights', 'maximum_nights',
       'minimum_minimum_nights', 'maximum_minimum_nights',
       'minimum_maximum_nights', 'maximum_maximum_nights',
       'minimum_nights_avg_ntm', 'maximum_nights_avg_ntm',
]

REVIEW_COLS = [
    'review_scores_rating', 'review_scores_accuracy',
       'review_scores_cleanliness', 'review_scores_checkin',
       'review_scores_communication', 'review_scores_location',
       'review_scores_value',
]

model_xgb_2 = xgboost.XGBRegressor()

dir = os.path.dirname(__file__)
model_xgb_2.load_model(os.path.join(dir,"model.json"))

def get_data_as_df(data):
    new_dico = {}
    new_dico["host_response_time"] = WORK_TO_RESPONSE_TIME_DICO[data["work"]]
    new_dico["host_response_rate"] = 97 #Median value of all respose rates.
    new_dico["host_acceptance_rate"] = 84 #Median
    new_dico["host_is_superhost"] = False
    new_dico["host_has_profile_pic"] = True
    new_dico['host_identity_verified'] = True
    new_dico['has_availability'] = True
    new_dico['instant_bookable'] = True

    for col in ['number_of_reviews', 'number_of_reviews_ltm', 'number_of_reviews_l30d',]:
        new_dico[col] = 0

    for col in direct_copy_cols:
        new_dico[col] = data[col]

    for col in nights_col:
        new_dico[col] = data["nights"]

    for col in REVIEW_COLS:
        new_dico[col] = WORK_TO_REVIEW_DICO[data["work"]]

    for col in ['calculated_host_listings_count',
        "host_listings_count",
        "host_total_listings_count",
       'calculated_host_listings_count_entire_homes',
       'calculated_host_listings_count_private_rooms',
       'calculated_host_listings_count_shared_rooms',]:
        new_dico[col] = 1

    df = pd.DataFrame({x: [new_dico[x]] for x in new_dico})
    for i in range(1, 7):
        df["bedroom_count_" + str(i)] = (df["bedrooms"] > (i - .5)) & (df["bedrooms"] < (i + .5))

    df["bedroom_count_7_+"] = df["bedrooms"] > 6.5

    for i in range(1, 5):
        df["bed_count_" + str(i)] = (df["beds"] > (i - .5)) & (df["beds"] < (i + .5))

    df["bed_count_5_+"] = df["beds"] > 4.5

    for i in range(1, 6):
        df["listing_count" + str(i)] = (df["calculated_host_listings_count"] > (i - .5)) & (
                    df["calculated_host_listings_count"] < (i + .5))

    df["listing_count_6_+"] = df["calculated_host_listings_count"] > 5.5

    df["owner_in_neighbourhood"] = df["neighbourhood_cleansed"] == df["host_neighbourhood"]

    for col in categorical_features:
        df[col] = df[col].astype('category')

    for col in df.columns:
        if df[col].dtype == "bool":
            df[col] = df[col].astype('category')


    return df

def predict(data):
    best_delay = 99999999999
    best_mini = None
    bast_maxi = None
    best_price = None
    work = data["work"]
    df = get_data_as_df(data)
    for renting_price in range(50,901,50):
        for mini_nights in range(0,31,5):
            for maxi_nights in range(mini_nights, 31,5):

                for col in nights_col:
                    if col.endswith("minimum_nights"):
                        df[col] = max(mini_nights, 1)
                    else:
                        df[col] = max(maxi_nights, 1)

                df["price"] = renting_price
                df = df[CORRECT_FEATURE_ORDER]
                delay = model_xgb_2.predict(df)
                if delay<best_delay:
                    best_delay = delay
                    best_price = renting_price
                    best_mini = mini_nights
                    bast_maxi = maxi_nights

    night_per_year = data["price_estimate"] / float(best_delay[0]) / best_price
    if work < 4:
        data["work"] = 4
        opti = predict(data)

        opti_delay = opti["Delay"]

        if best_delay - opti_delay >1:
            return {"Price": best_price, "Delay": round(float(best_delay[0]), 2), "MinNights": best_mini,
                "MaxNights": bast_maxi, "OptiDelay":opti_delay,
                "NPY": round(night_per_year, 2), }

    #print ({"Price": best_price, "Delay":round(float(best_delay[0]),2), "MinNights": best_mini, "MaxNights": bast_maxi})
    return {"Price": best_price, "Delay":round(float(best_delay[0]),2), "MinNights": best_mini,
            "MaxNights": bast_maxi, "NPY": round(night_per_year, 2)}

@csrf_exempt
def handlePredictRequest(request):
    print(request.body)
    json_dict = json.loads(request.body)
    result = predict(json_dict)
    return JsonResponse(result)



