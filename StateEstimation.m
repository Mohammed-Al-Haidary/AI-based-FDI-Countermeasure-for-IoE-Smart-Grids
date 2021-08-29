function ser = StateEstimation(results)

%% which measurements are available
idx.idx_zPF = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20];
idx.idx_zPT = [4;5;7;11];
idx.idx_zPG = [1;2;3;4;5];
idx.idx_zVa = [];
idx.idx_zQF = [1;3;8;9;10;13;15;19];
idx.idx_zQT = [4;5;7;11];
idx.idx_zQG = [1;2];
idx.idx_zVm = [2;3;6;8;10;14];

%% specify measurements
measure.PF = results.branch(:,14);

measure.PT = [];
for i = 1: length(idx.idx_zPT)
	measure.PT = [measure.PT; results.branch(idx.idx_zPT(i),16);];
end

measure.PG = [];
for i = 1: length(idx.idx_zPG)
	measure.PG = [measure.PG; results.gen(idx.idx_zPG(i),2);];
end

measure.Va = [];

measure.QF = [];
for i = 1: length(idx.idx_zQF)
	measure.QF = [measure.QF; results.branch(idx.idx_zQF(i),15);];
end

measure.QT = [];
for i = 1: length(idx.idx_zQT)
	measure.QT = [measure.QT; results.branch(idx.idx_zQT(i),17);];
end

measure.QG = [];
for i = 1: length(idx.idx_zQG)
	measure.QG = [measure.QG; results.branch(idx.idx_zQG(i),3);];
end

measure.Vm = [1;1;1;1;1;1];

%% specify measurement variances
sigma.sigma_PF = 0.02;
sigma.sigma_PT = 0.02;
sigma.sigma_PG = 0.015;
sigma.sigma_Va = [];
sigma.sigma_QF = 0.02;
sigma.sigma_QT = 0.02;
sigma.sigma_QG = 0.015;
sigma.sigma_Vm = 0.01;

%% check input data integrity
nbus = 14;
[success, measure, idx, sigma] = checkDataIntegrity(measure, idx, sigma, nbus);
if ~success
    error('State Estimation input data are not complete or sufficient!');
end
    
%% run state estimation
casename = 'CustomCase14.m';
type_initialguess = 2; % flat start
[baseMVA, bus, gen, branch, success, et, z, z_est, error_sqrsum] = run_se(casename, measure, idx, sigma, type_initialguess);
ser.z = z;
ser.z_est = z_est;
