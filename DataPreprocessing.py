import pandas as pd

# Pandas Display Options
pd.set_option('display.min_rows', 60)
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)

print("Preprocessing IHEPCDS dataset...", end="")

# Import raw data
filePath = r"RawDataset\household_power_consumption.txt"
df = pd.read_csv(filePath, header=0, sep='\t', dtype={'Global_active_power': 'object',
                                                      'Global_intensity': 'object',
                                                      'Global_reactive_power': 'object',
                                                      'Sub_metering_1': 'object',
                                                      'Sub_metering_2': 'object',
                                                      'Sub_metering_3': 'object',
                                                      'Voltage': 'object'})

# Drop irrelevant columns
removeList = ['Voltage', 'Global_intensity', 'Date', 'Time', 'Sub_metering_1', 'Sub_metering_2', 'Sub_metering_3']
df.drop(removeList, axis=1, inplace=True)

# Clean the dataframe from Null rows
df = df[~df.select_dtypes(['object']).eq('?').any(1)]

# Set column data types. Ensures power data is only float.
conversionDict = {'Global_active_power': float,
                  'Global_reactive_power': float
                  }
df = df.astype(conversionDict)

# Split the dataframe into eleven
pieceSize = int(len(df) / 11)
dfs = []
for i in range(0, 11):
    startingIndex = (pieceSize * i) + 1  # Will ignore the first row
    endingIndex = pieceSize * (1 + i)
    splitDf = df[startingIndex:endingIndex].reset_index(drop=True)  # Reindex

    # Rename columns
    activeName = 'Active' + str(i)
    reactiveName = 'Reactive' + str(i)
    splitDf.columns = [activeName, reactiveName]

    dfs.append(splitDf)

# Merge the two dataframes side by side
df = pd.concat(dfs, axis=1)

# Save the dataframes as a csv file
df.to_csv(r"RegroupedDataset\RegroupedData.csv", index=False, header=False)

print("Completed")
