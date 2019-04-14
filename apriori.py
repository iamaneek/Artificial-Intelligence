import numpy as np  
import matplotlib.pyplot as plt  
import pandas as pd  
from apyori import apriori 
import time 
import statistics
import argparse

def csvToList(csvFile):
	'''This function reads the csv object and converts to List
	args: CSV file object
	return:List'''
	tempRecord = [] 
	
	for i in range(0, 1000):
	#	print(i)    
		tempRecord.append([str(csvFile.values[i,j]) for j in range(0, 20)])

	return tempRecord

def applyApriori(dataList,support,timeList):
	'''this function aplies the apriori algorithm to the lis
	args:List containing the data related to transactions;supportList: The minimum support for the apriori  
	return:List (the association result as a list)'''
    
	startTime = time.time()
	association_rules = apriori(dataList, min_support=support, min_confidence=0.2, min_lift=3, min_length=2) 
	timeList.append(time.time() - startTime)
	association_results = list(association_rules)

	return association_results


def getVariousMetrics(association_results):
	'''The function decodes the association result list  returns the mean confidence
	args:List(association_results)
	return: float (mean confidence value)''' 
	
	tempList = []
	for item in association_results:
    		pair = item[0] 
    		items = [x for x in pair]
    		tempList.append( float(str(item[2][0][2])))

	if len(tempList) != 0:
		return 	statistics.mean(tempList)
	else:
		return 0 	

def argsParser():
	'''The function is responsible for parsing the arguments
	args:None
	return:args a dictionary'''
	
	parser = argparse.ArgumentParser()
	parser.add_argument('--filePath', type = str, default = './store_data.csv', help='The absolute path of csv file'  )
	args = parser.parse_args()
	return args


def main():

	'''All the steps are performed in this function
	args:None
	return:None'''
	args = argsParser() 
	store_data = pd.read_csv(args.filePath)
	supportList = [0.0045,0.0055,0.0065,0.0075,0.0085,0.0095,0.0105]
	timeList = []
	ruleLength = []
	confidenceList = []
	finalConfidenceList = []
	records = csvToList(store_data)
	associationResults = []
	for support in supportList:
		associationResults = applyApriori(records,support,timeList)
		ruleLength.append(len(associationResults))
		confidenceList.append(getVariousMetrics(associationResults))	
		
	print('support list:{}'.format(supportList))
	print('confidenceList:{}'.format(confidenceList))
	print('timeList:{}'.format(timeList))
	print('ruleLength:{}'.format(ruleLength))

if __name__ == '__main__':
	main()
