
# Overview

This repository has been created to develop a machine learning model and an application designed to provide users with insights into purchasing properties for rental in the Airbnb market. It includes datasets, Jupyter notebooks for data processing and model development, and the final application consisting of a backend developed in Django and a frontend in Flutter.

## Purpose

The main goal is to aid potential property investors and Airbnb hosts in making informed decisions by analysing various aspects of the real estate and Airbnb rental market. Through the use of machine learning, this project aims to offer valuable predictions and insights about market trends, pricing, and other relevant factors.

## Datasets

The datasets are crucial for our machine learning module. Below are the sources and descriptions:

- **Land Registry Data:** Obtained from [Land Registry](https://landregistry.data.gov.uk/), this dataset is sourced through [Plumplot](https://a.plumplot.co.uk/).
- **London Airbnb Market:** This dataset is specific to the Airbnb market in London and was downloaded from [Inside Airbnb](https://insideairbnb.com/get-the-data/).

## Jupyter Notebooks

The project's computational notebooks are organized as follows:

- **cleaning_and_merging_final:** This Jupyter notebook processes and merges various datasets to form a clean, consolidated dataset. The resulting file, `cleaned_and_merged.csv`, is located in the datasets folder.
- **Exploration_and_model_final:** This notebook is used for the final exploration of the data and for building the machine learning model. The model is then exported as `model.json` in the main directory.

## Final Application

The application developed to utilize the machine learning model consists of both backend and frontend components:

- **Backend:** Developed in Python using the Django framework. It incorporates the `model.json`.
- **Frontend:** Created using Flutter for a seamless user experience.

The `Release` folder within the `final_app` directory contains the executable file, ready for user deployment.

### Setup and Installation

To run the final application, it needs to be installed the following libraries:


- `pip install numpy`
- `pip install pandas`
- `pip install xgboost`
- `pip install sklearn`
- `pip install django`


### Running the Backend
1. Navigate to the `final_app` folder.
2. Navigate to the `backend` folder.
3. Locate the `manage.py` file inside the `predicts` folder.
4. Open the command line in this folder.
5. Run the server using the command: 
   
   `python manage.py runserver 8080`

### Running the Frontend

1. Ensure the backend server is running as described above.
2. Navigate to the `Release` folder in the `final_app` directory.
3. On a Windows machine, double-click the executable file `predictor_app_frontend` to start the frontend application.




### 6001CEM Thesis

For a more comprehensive understanding of the construction and design of each component in this repository, please refer to the accompanying thesis. The thesis provides an in-depth explanation of all aspects of this project.
