#!/usr/bin/env python
# coding: utf-8

# # The Guardian Article Distribution Analysis
# 
# Utilized The Guardian's API to get articles from <u>2000 -  present</u> with the keyword "**Philippines**," followed by analysis, with the general goal of looking into the distribution of articles across a period of time and gaining insights into the newspaper's editorial focus.
# 
# Skills used:
# - acquired data using API
# - utilized pandas, matplotlib, nltk and collections libraries
# - tried a bit of Natural Language Processing
# - EDA on The Guardian's articles
# 
# Findings:
# - The Guardian published the most articles in years **2013 and 2020**. 
# - In 2013, **November** outstandingly saw the most published articles for the year. 
# - In November 2013:
#  - The surge of articles published seems to be because of the **Haiyan Typhoon, or Super Typhoon Yolanda** as known by the Filipino locals, according to an analysis of article headlines published at that time.
#  - Unsurprisingly, the most common sections were **'World news' and 'Environment.'**
# - In 2020, most articles were published in **February, March and April**.
# - In Feb.-Apr. 2020:
#  - Upon analysis of the article headlines published, it seems that the high publication rate was because of the **COVID-19 pandemic**.
#  - Majority of the articles were in the **'World news'** section.
# - Overall, The Guardian's most common news products related to the "Philippines" are **articles, followed by liveblogs**. The most common section was overwhelmingly **'World news,' followed distantly by 'Opinion' and 'Environment'**.
# 
# 
# Further analysis:
# - An analysis, sentiment analysis for example, of opinion articles about the Philippines, due to the interesting result that 'Opinion' is the second most common article section overall.
# 
# 
# Data Acquisition adopted from Analyst Adithya's video (https://youtu.be/Nf1U62XxDmU?si=yq4TXr0USzKLca6S)

# In[45]:


# API key: here


# In[46]:


url = 'https://content.guardianapis.com/search?q=philippines&from-date=2000&api-key=putHere'


# In[2]:


# import libraries

import pandas as pd
import requests

import matplotlib.pyplot as plt
from nltk.corpus import stopwords
from collections import Counter


# In[3]:


response = requests.get(url)
print(response)


# In[4]:


# json

x = response.json()
print(x)


# In[5]:


# loop through all pages

urllist = []

for i in range(1,857):
    a = 'https://content.guardianapis.com/search?q=philippines&from-date=2000&api-key=e9eaf2ef-00d6-47a6-89cf-10386627a2f2&page='
    b = str(i)
    c = a+b
    urllist.append(c)

urllist


# In[6]:


# function to read all the urls in urllist into json

info = []

def json(url1):
    response = requests.get(url1)
    x = response.json()
    info.append(x)


# In[7]:


# run json function in all url

output = [json(url1) for url1 in urllist]


# In[8]:


info


# In[9]:


# finding total number of pages
info[0]['response']['pages']


# In[10]:


# getting result of the 10th latest article headline
info[0]['response']['results'][9]['webTitle']


# In[11]:


# looping through all the articles to get specific info for analysis

finallist = []

try:
    for page in range(0,857):
        for article in range (0, 10):
            value = dict(
            webtitle = info[page]['response']['results'][article]['webTitle'],
            sectionname = info[page]['response']['results'][article]['sectionName'],
            pubdate = info[page]['response']['results'][article]['webPublicationDate'],
            type = info[page]['response']['results'][article]['type']
            )
            finallist.append(value)
except IndexError:
    print('done')


# In[12]:


finallist


# In[13]:


# make 'finallist' into DataFrame

newdata = pd.DataFrame(finallist)
newdata


# In[14]:


# remove time in pubdate

newdata['pubdate'] = newdata['pubdate'].str.split('T').str[0]

newdata


# # ANALYSIS

# In[15]:


# convert 'pubdate' to datetime
newdata['pubdate'] = pd.to_datetime(newdata['pubdate'])

newdata


# ## Published articles by year and month

# In[16]:


# group and count the number of articles by year and month
date_count = newdata.groupby([newdata['pubdate'].dt.year, newdata['pubdate'].dt.month_name()])['pubdate'].count()

print(date_count)


# In[17]:


# count articles published per year, sort the index to be chronological

year_count = newdata['pubdate'].dt.year.value_counts().sort_index()

print(year_count)


# In[18]:


# create a line graph to present above data

plt.figure(figsize=(15, 5))
plt.plot(year_count.index, year_count.values, marker='o')
plt.title('Total Articles per Year')
plt.xlabel('Year')
plt.ylabel('Articles Published')
plt.grid(True)
plt.xticks(year_count.index)

plt.show()


# ### Investigate the rise of articles published in 2013

# In[19]:


# publication count per month in 2013

# filter 2013

yr_2013 = newdata[newdata['pubdate'].dt.year == 2013]

month_count_2013 = yr_2013['pubdate'].dt.month.value_counts().sort_index()

print(month_count_2013)


# In[20]:


# create a bar graph to present above data

plt.bar(month_count_2013.index, month_count_2013.values)
plt.title('Total Articles per Month in 2013')
plt.xlabel('Month')
plt.ylabel('Articles Published')
plt.grid(axis='y')

# change x-axis to month names
month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
plt.xticks(range(1, 13), month_names, rotation=45)

plt.show()


# ### Identify the most common topic of articles published in Nov. 2013
# 

# In[27]:


# filter articles for November 2013
nov2013 = newdata[(newdata['pubdate'].dt.year == 2013) & (newdata['pubdate'].dt.month == 11)]


# In[28]:


# most common words used in headline

cus_stopwords = stopwords.words('english') + ['says', 'say']

# function to preprocess and count words

def word_count(text):
    # split webtitle into words
    words = text.split()

    # remove punctuations, covert to lowercase
    words = [word.strip(' .,-–!?(){}[]"\'|/').lower() for word in words]
    
    # remove stopwords
    words = [word for word in words if word not in cus_stopwords]
    
    # filter empty strings
    words = [word for word in words if word]
    
    # count words
    word_count = Counter(words)
    
    return word_count


# apply function
words_count = nov2013['webtitle'].apply(word_count)

# combine word counts from all rows
combined_counts = words_count.sum()

# get most common words
common_words = combined_counts.most_common()

# print
print(common_words[:10])


# In[29]:


# type count

type_count = nov2013['type'].value_counts()

print(type_count)


# In[36]:


# section count for Nov. 2013 articles

section_count = nov2013['sectionname'].value_counts()

print(section_count)


# ### Investigate the rise of published articles in 2020

# In[25]:


# publication count per month in 2020

# filter 2020

yr_2020 = newdata[newdata['pubdate'].dt.year == 2020]

month_count_2020 = yr_2020['pubdate'].dt.month.value_counts().sort_index()

print(month_count_2020)


# In[26]:


# create a bar graph to present above data

plt.bar(month_count_2020.index, month_count_2020.values)
plt.title('Total Articles per Month in 2020')
plt.xlabel('Month')
plt.ylabel('Articles Published')
plt.grid(axis='y')

# change x-axis to month names
month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
plt.xticks(range(1, 13), month_names, rotation=45)

plt.show()


# ### Investigate the rise of published articles in Februrary - April 2020

# In[32]:


# filter articles for Feb-April 2020
f_a2020 = newdata[(newdata['pubdate'].dt.year == 2020) & (newdata['pubdate'].dt.month.isin([2, 3, 4]))]


# In[33]:


# type count

type_count = nov2013['type'].value_counts()

print(type_count)


# In[35]:


# section count for Feb-April 2020 articles

section_count2020 = f_a2020['sectionname'].value_counts()

print(section_count2020)


# In[40]:


# most common words used in headline

cus_stopwords = stopwords.words('english') + ['says', 'say', 'happened']

# apply word_count function
words_count2020 = f_a2020['webtitle'].apply(word_count)

# combine word counts from all rows
combined_counts2020 = words_count2020.sum()

# get most common words
common_words2020 = combined_counts2020.most_common()

# print
print(common_words2020[:10])


# # Analysis of ALL articles acquired

# In[41]:


# type count

type_count_all = newdata['type'].value_counts()

print(type_count_all)


# In[42]:


# section count

section_count_all = newdata['sectionname'].value_counts()

print(section_count_all)


# In[44]:


# headline word count

# most common words used in headline

cus_stopwords = stopwords.words('english') + ['says', 'say', 'happened']

# apply word_count function
words_count_all = newdata['webtitle'].apply(word_count)

# combine word counts from all rows
combined_count_all = words_count_all.sum()

# get most common words
common_words_all = combined_count_all.most_common()

# print
print(common_words_all[:20])

