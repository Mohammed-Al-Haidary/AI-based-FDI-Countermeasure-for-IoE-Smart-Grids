import pandas as pd
from WndowGenerator import WindowGenerator as WG
import tensorflow as tf
import tensorflow.keras as keras
import os

# Pandas Display Options
pd.set_option('display.min_rows', 60)
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)


def compileAndFit(inputModel, inputWindow, patience=2):
    early_stopping = tf.keras.callbacks.EarlyStopping(monitor='val_loss',
                                                      patience=patience,
                                                      mode='min')

    inputModel.compile(loss=tf.losses.MeanSquaredError(),
                       optimizer=tf.optimizers.Adam(learning_rate=0.01),
                       metrics=[tf.metrics.MeanAbsoluteError()])

    inputModel.fit(inputWindow.train, epochs=20,
                   validation_data=inputWindow.val,
                   callbacks=[early_stopping])

    inputModel.save(r'Model\model.h5')

    return inputModel


columnNames = []
for i in range(0, 25):
    columnNames.append(str(i))

# untamperedData is to be loaded for training
filePath = r'VectorDataset\untamperedVectorData.csv'
df = pd.read_csv(filePath, header=None, names=columnNames)

# Split the data
trainSplit = int(len(df) * 0.7)
valSplit = int(len(df) * 0.9)

trainDf = df[0:trainSplit]
valDf = df[trainSplit:valSplit]
testDf = df[valSplit:]
denormalizedTest = testDf.copy(deep=True)

numFeatures = df.shape[1]

# Create windows
window = WG(input_width=5, label_width=1, shift=1, train_df=trainDf, val_df=valDf, test_df=testDf,
            label_columns=None)

model = keras.models.Sequential()
model.add(keras.layers.LSTM(64, activation="tanh", return_sequences=True))
model.add(keras.layers.Dense(units=64, activation='linear'))
model.add(keras.layers.LSTM(64, activation="tanh", return_sequences=True))
model.add(keras.layers.Dense(units=64, activation='linear'))
model.add(keras.layers.LSTM(64, activation="tanh", return_sequences=True))
model.add(keras.layers.Dense(units=64, activation='linear'))
model.add(keras.layers.Dense(25))

# Check for a model and load it if found
modelFolder = r'Model'
if len(os.listdir(modelFolder)) != 0:
    model = tf.keras.models.load_model(modelFolder + r'\model.h5')
    print("Loaded last saved model")
else:
    print("No saved model found. Starting anew")

model = compileAndFit(model, window)
