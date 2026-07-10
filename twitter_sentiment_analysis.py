import re
import seaborn as sns
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
import numpy as np
import pandas as pd
import nltk
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
pd.set_option('display.max_columns', None)
pd.set_option('display.width',1000)
from concurrent.futures import ThreadPoolExecutor
from tqdm import tqdm
import pickle
#stop words
#nltk.download('stopwords')

#print(stopwords.words('english'))

#load dataframe
twitter_data = pd.read_csv('material/training.1600000.processed.noemoticon.csv',encoding='ISO-8859-1')

print(twitter_data.head())

print(twitter_data.shape)

#naming columns

column_names = ['target', 'id', 'date', 'flag', 'user', 'text']

#add column names to dataframe

twitter_data = pd.read_csv('material/training.1600000.processed.noemoticon.csv',names=column_names,encoding='ISO-8859-1')

print(twitter_data.head())


# counting number of missing values in dataframe
print(twitter_data.isnull().sum())

#check distribution of target column
print(twitter_data['target'].value_counts())


# Initialize stopwords
stop_words = set(stopwords.words('english'))

def stemming(content):
    try:
        port_stem = PorterStemmer()  # Instantiate inside the function
        stemmed_content = re.sub('[^a-zA-Z]', ' ', content).lower()
        return ' '.join(port_stem.stem(word) for word in stemmed_content.split() if word not in stop_words)
    except Exception as e:
        print(f"Error processing content: {content}. Error: {e}")
        return ""  # Return an empty string on error

def process_data(df):
    with ThreadPoolExecutor() as executor:
        return list(tqdm(executor.map(stemming, df['text']), total=len(df)))

# Process the DataFrame in chunks
chunk_size = 50000  # Adjust based on your memory capacity
num_chunks = len(twitter_data) // chunk_size + 1
stemmed_contents = []

for i in tqdm(range(num_chunks)):
    start = i * chunk_size
    end = min((i + 1) * chunk_size, len(twitter_data))
    chunk = twitter_data.iloc[start:end]
    stemmed_chunk = process_data(chunk)
    stemmed_contents.extend(stemmed_chunk)

# Add the stemmed content back to the DataFrame
twitter_data['stemmed_content'] = stemmed_contents

print(twitter_data.head())

# Separating data and label

X = twitter_data['stemmed_content'].values
Y = twitter_data['target'].values

### Splitting data to training data and test data

X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2, stratify=Y, random_state=2)

# Converting actual data into numerical data

vectorizer = TfidfVectorizer()

X_train = vectorizer.fit_transform(X_train)

X_test = vectorizer.transform(X_test)

### Training ML model

#Logistic Regression
model = LogisticRegression(max_iter=1000)

model.fit(X_train,Y_train)

### Model Evaluation

#Accuracy Score

# Accuracy score on training data
X_train_prediction = model.predict(X_train)
training_data_accuracy = accuracy_score(Y_train, X_train_prediction)

print('Accuracy Score of training data: ', training_data_accuracy)

# Accuracy score on test data
X_test_prediction = model.predict(X_test)
test_data_accuracy = accuracy_score(Y_test, X_test_prediction)

print('Accuracy Score of test data: ', test_data_accuracy)

# Model Accuracy = 77.6%


### Saving trained model

filename = 'trained_model.sav'

pickle.dump(model, open(filename, 'wb'))

