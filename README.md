# AI-based-FDI-Countermeasure-for-IoE-Smart-Grids
The codebase for an AI-Based detection system to detect False Data Injection Attacks (FDIA) – the most sophisticated and damaging attack against smart power grids until date.

Python and MATLAB were the used programming languages. Used MATPOWER, Tensorflow, Keras, and Pandas frameworks. LSTM (RNN variant) was employed to solve the time series forecasting problem.

**Repository Files**
- DataProcessing.py prepares the dataset for training.
- Training.py and WindowGenerator.py trains the LSTM-based model using the prepared dataset.
- Simulation.m simulates the FDIA on the prepared dataset.
- StateEstimation.m and CustomCase14.m are supporting files used by Simulation.m
- Evaluation.py implements the detection mechanism to test the accuracy of the system.
