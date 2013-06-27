% DEM_SGPLVM_FOLS Runs Demo of FOLS SGPLVM model
% FORMAT
% DESC None
% ARG : None

% SGPLVM

clear all;
close all;

alpha = linspace(0,2*pi,100);
Z1 = cos(alpha)';
Z2 = sin(alpha)';

% Scale and center data
bias_Z1 = mean(Z1);
Z1 = Z1 - repmat(bias_Z1,size(Z1,1),1);
scale_Z1 = max(max(abs(Z1)));
Z1 = Z1 ./scale_Z1;

bias_Z2 = mean(Z2);
Z2 = Z2 - repmat(bias_Z2,size(Z2,1),1);
scale_Z2 = max(max(abs(Z2)));
Z2 = Z2 ./ scale_Z2;

% Latent Initialisation
latent_shared = size(Z1,2) + size(Z2,2);
latent_dim = latent_shared + size(Z1,2) + size(Z2,2);
Pxy = [Z1 Z2];

latent_p1 = size(Z1,2);
Px = Z1;

latent_p2 = size(Z2,2);
Py = Z2;

% GPLVM parameters
options_y = fgplvmOptions('ftc');
options_y.prior = [];
options_y.optimiser = 'scg';
options_y.scale2var1 = false;
options_y.initX = [Pxy ,Px ,Py];
latent_dim = size(options_y.initX,2);

% Create GPLVM models
model{1} = fgplvmCreate(latent_dim,size(Z1,2),Z1,options_y);
model{1}.bias = bias_Z1;
model{1}.scale = repmat(scale_Z1,1,size(Z1,2));
model{2} = fgplvmCreate(latent_dim,size(Z2,2),Z2,options_y);
model{2}.bias = bias_Z2;
model{2}.scale = repmat(scale_Z2,1,size(Z2,2));

% set indices
model{1} = sgplvmSetLatentDimension(model{1},'gen',[1:latent_shared+latent_p1],true);
model{2} = sgplvmSetLatentDimension(model{2},'gen',[1:latent_shared,latent_shared + latent_p1+1:latent_dim],true);


% SGPLVM paramters
options = sgplvmOptions;
options.save_intermediate = inf;
options.name = 'circle';
options.initX = zeros(2,latent_dim);
options.initX(1,:) = true;
options.initX(2,:) = false;

% FOLS parameters
options.fols = sgplvmFOLSOptions;
options.fols.cropp = true;
options.fols.cropp_iter = 10;
options.fols.cropp_ratio = 0.05;

options.fols.rank.alpha.weight = 50;
options.fols.rank.alpha.decay.rate = -0.5;
options.fols.rank.alpha.decay.shift = 100;
options.fols.rank.alpha.decay.truncate = 0;

options.fols.rank.beta.weight = 1;
options.fols.rank.beta.decay.rate = 0;
options.fols.rank.beta.decay.shift = 0;
options.fols.rank.beta.decay.truncate = 0;

options.fols.rank.gamma.weight = 5e-2;
options.fols.rank.gamma.decay.rate = 0;
options.fols.rank.gamma.decay.shift = 0;
options.fols.rank.gamma.decay.truncate = 0;

options.fols.ortho.weight = 10;
options.fols.ortho.decay.rate = 0;
options.fols.ortho.decay.shift = 100;
options.fols.ortho.decay.truncate = 0;

% Create SGPLVM model
model = sgplvmCreate(model,[],options);

model = sgplvmOptimise(model,true,800,false,false,options);

% display results
figure(1);
plot(Pxy(:,1),Pxy(:,2));
figure(2);
plot(model.X(:,1),'b');
hold on;
plot(model.X(:,2),'c');
plot(model.X(:,3),'g');
legend({'Shared','Private Y1','Private Y2'});