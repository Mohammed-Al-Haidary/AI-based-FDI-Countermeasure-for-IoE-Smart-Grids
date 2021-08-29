function Simulation

%------------------------------------------------------------------------------%
% One-off Declarations
mpc = loadcase('case14');

%------------------------------------------------------------------------------%
% Import raw dataset
rawDataset = csvread('RegroupedDataset\RegroupedData.csv');

%------------------------------------------------------------------------------%
% Power Flow Analysis
untamperedVectors = [];
tamperedVectors = [];
labels = [];

actives = [];
reactives = [];

for j = 1:67195 % j is the Time step
	%--------------------------------------------%
	% Split active and reactive power measurements
	tempActives = [];
	tempReactives = [];
	for i = 1:22
		if mod(i,2) ~= 0
			tempActives = [tempActives, rawDataset(j,i)];
		else
			tempReactives = [tempReactives, rawDataset(j,i)];
		end
	end
	actives = [actives; tempActives];
	reactives = [reactives; tempReactives];

	%--------------------------------------------%
	% Set the case file parameters
	cell = 1;
	for i = 2:14
		if (i ~= 7) && (i ~= 8)
			mpc.bus(i,2) = 1; % Set as load bus
			mpc.bus(i,3) = actives(index,cell);
			mpc.bus(i,4) = reactives(index,cell);
			cell = cell + 1;
		end
	end
	% Set as generator buses
	mpc.bus(7,2) = 2;
	mpc.bus(8,2) = 2;
	
	% Save the casefile and run the power flow analysis
	savecase('CustomCase14.m', mpc);
	results = rundcpf(mpc);
	
	%--------------------------------------------%
	% Create the measurement vector
	realPowerInjections = results.bus(:,3);
	realPowerFlows = results.branch(:,14);
	
	measurementVector = [realPowerInjections; realPowerFlows];
	
	%--------------------------------------------%
	% Decide if measurement vector is to be falsified
	r = randi([0 100], 1, 1); % Generate a random number from 0 to 100
	
	if(r < 20) && (j > 62475) % Do not falsify the first 2k measurements of the testing dataset
		decision = true; % 20 percent chance of falsification
	else
		decision = false;
	end
	
	labels = [labels; decision];

	%--------------------------------------------%
	% Perform state estimation
	ser = StateEstimation(results);
	
	%--------------------------------------------%
	% Compute the Jacobian matrix for the bus system
	H = makeJac(mpc);
	
	jacLen = length(H);
	
	%--------------------------------------------%
	% Save measurement vector to untamperedVectors
	measurementVector = measurementVector(1:jacLen);
	untamperedVectors = [untamperedVectors, measurementVector];
	
	%--------------------------------------------%
	% Falsification if decided
	if j > 60475 % Falsify only the testing portion (last 10%)
		if ~decision
			% Append the untampered measurement vector
			tamperedVectors = [tamperedVectors, measurementVector];
		else
			% Compute error vector
			error = [];
			for i = 1:14
				error = [error; 0];
			end
		
			ser.z = ser.z(1:20);
			ser.z_est = ser.z_est(1:20);
			flowsError = ser.z - ser.z_est;
			error = [error; flowsError];
			error = error(1:jacLen);
			
			% Compute attack vector
			r = randi([1 10], 1, 1); % Generate a random number from 0 to 100
			
			c = [];
			for i = 1:jacLen
				c = [c, r];
			end
			c = transpose(c);
			
			% Compute the falsified measurement vector
			za = measurementVector + (H*c) + error;
			
			% Append the tampered measurement vector
			tamperedVectors = [tamperedVectors, za];
		end
	end
	
	status = strcat(int2str(j), '/', int2str(67195), ' simulations complete');
	disp(status)
end

untamperedVectors = transpose(untamperedVectors);
tamperedVectors = transpose(tamperedVectors);

%------------------------------------------------------------------------------%
% Save results
writematrix(untamperedVectors, 'VectorDataset\untamperedVectorData.csv')
writematrix(tamperedVectors, 'VectorDataset\tamperedVectorData.csv')
writematrix(labels, 'VectorDataset\labelData.csv')