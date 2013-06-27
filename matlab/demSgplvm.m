% DEMSGPLVM Demonstrate the SGPLVM.

% SGPLVM

clear all close all;

% 1. Set types
sgplvm_model_type = 'mlmi2008';%'mlmi2007';%'nips2006';
data_type = 'human';
nr_iters = 10;

% 2. Load Data
switch data_type
 case 'rand'
  Y_train = rand(100,30);
  Z_train = rand(100,10);
  Ky = Y_train*Y_train';
  Kz = Z_train*Z_train';
  seq = [4 13 100];
 case 'human'
  load('nccaDemoData.mat');
 otherwise
  error('Unkown Data Type');
end

if(size(Y_train,1)>100)
  approx = 'fitc';
else
  approx = 'ftc';
end

% 3. Learn Initialisation through NCCA
[Xsy Xsz Xy Xz] = nccaEmbed(Y_train,Z_train,uint8([7 7]),uint8(1),uint8([2 2]),true);

Xs = (1/2).*(Xsy+Xsz);
X_init = [Xy Xs Xz];
X_init = (X_init-repmat(mean(X_init),size(X_init,1),1))./repmat(std(X_init),size(X_init,1),1);

% 4. Create SGPLVM model
switch sgplvm_model_type
 case 'nips2006'
  options_y = fgplvmOptions(approx);
  options_y.optimiser = 'scg';
  options_y.scale2var1 = true;
  options_y.initX = X_init;
  
  model{1} = fgplvmCreate(size(options_y.initX,2),size(Y_train,2),Y_train,options_y);
  model{1} = sgplvmSetLatentDimension(model{1},'gen',1:1:size(X_init,2),true);
    
  options_z = fgplvmOptions(approx);
  options_z.optimiser = 'scg';
  options_z.scale2var1 = true;
  options_z.initX = X_init;
  
  model{2} = fgplvmCreate(size(options_z.initX,2),size(Z_train,2),Z_train,options_z);
  model{2} = sgplvmSetLatentDimension(model{2},'gen',1:1:size(X_init,2),true);
 
  options = sgplvmOptions;
  options.save_intermediate = inf;
  options.name = 'nips2006';
  options.initX = zeros(2,size(X_init,2));
  options.initX(1,:) = true;
  options.initX(2,:) = false;
  
  model = sgplvmCreate(model,[],options);
 case 'mlmi2007'
  options_y = fgplvmOptions(approx);
  options_y.optimiser = 'scg';
  options_y.scale2var1 = true;
  options_y.initX = X_init;
 
  model{1} = fgplvmCreate(size(options_y.initX,2),size(Y_train,2),Y_train,options_y);
  model{1} = sgplvmSetLatentDimension(model{1},'gen',1:1:size(X_init,2),true);
    
  options_z = fgplvmOptions(approx);
  options_z.optimiser = 'scg';
  options_z.scale2var1 = true;
  options_z.initX = X_init;
  options_z.back = 'kbr';
  options_z.backOptions.kern = kernCreate(Y_train,'rbf');
  options_z.backOptions.X = Y_train;
  options_z.backOptions.kern.inverseWidth = 1e2;
  options_z.optimiseInitBack = true;  
  
  model{2} = fgplvmCreate(size(options_z.initX,2),size(Z_train,2),Z_train,options_z);
  model{2} = sgplvmSetLatentDimension(model{2},'gen',1:1:size(X_init,2),true);
  model{2} = sgplvmSetLatentDimension(model{2},'back',1:1:size(X_init,2),true);
  
  options = sgplvmOptions;
  options.save_intermediate = inf;
  options.name = 'sgplvm_ncca_test_';
  options.initX = zeros(2,size(X_init,2));
  options.initX(1,:) = true;
  options.initX(2,:) = false;

  model = sgplvmCreate(model,[],options);

  model = sgplvmAddDynamics(model,'gp',[size(Xy,2)+1:1:size(X_init,2)],[size(Xy,2)+1:1:size(X_init,2)],X_init,gpOptions(approx),1,1,seq);
  
 case 'mlmi2008'
  options_y = fgplvmOptions(approx);
  options_y.optimiser = 'scg';
  options_y.scale2var1 = true;
  options_y.initX = X_init;
  options_y.back = 'kbr';
  options_y.backOptions.kern = kernCreate(Y_train,'rbf');
  options_y.backOptions.X = Y_train;
  options_y.backOptions.kern.inverseWidth = 1e2;
  options_y.optimiseInitBack = true;
  
  model{1} = fgplvmCreate(size(options_y.initX,2),size(Y_train,2),Y_train,options_y);
  model{1} = sgplvmSetLatentDimension(model{1},'gen',[1:1:size([Xy Xs],2)],true);
  model{1} = sgplvmSetLatentDimension(model{1},'back',[size(Xy,2)+1:1:size([Xy Xs],2)],true);
  
  options_z = fgplvmOptions(approx);
  options_z.optimiser = 'scg';
  options_z.scale2var1 = true;
  options_z.initX = X_init;
  
  model{2} = fgplvmCreate(size(options_z.initX,2),size(Z_train,2),Z_train,options_z);
  model{2} = sgplvmSetLatentDimension(model{2},'gen',[size(Xy,2)+1:1:size(X_init,2)],true);
 
  options = sgplvmOptions;
  options.save_intermediate = inf;
  options.name = 'sgplvm_ncca_test_';
  options.initX = zeros(2,size(X_init,2));
  options.initX(1,:) = true;
  options.initX(2,:) = true;

  model = sgplvmCreate(model,[],options);

  model = sgplvmAddDynamics(model,'gp',[size(Xy,2)+1:1:size(X_init,2)],[size(Xy,2)+1:1:size(X_init,2)],X_init,gpOptions(approx),1,1,seq);
 case 'dgplvm'
  
  options_y = fgplvmOptions(approx);
  options_y.optimiser = 'scg';
  options_y.scale2var1 = true;
  
  X_init = X_init(:,1:2);
  
  options_y.initX = X_init;
  
  model{1} = fgplvmCreate(size(options_y.initX,2),size(Y_train,2),Y_train,options_y);
  model{1} = sgplvmSetLatentDimension(model{1},'gen',1:1:size(X_init,2),true);
  
  options_z = fgplvmOptions(approx);
  options_z.optimiser = 'scg';
  options_z.scale2var1 = true;
  options_z.initX = X_init;
  
  model{2} = fgplvmCreate(size(options_z.initX,2),size(Z_train,2),Z_train,options_z);
  model{2} = sgplvmSetLatentDimension(model{2},'gen',1:1:size(X_init,2),true);
  
  options = sgplvmOptions;
  options.save_intermediate = inf;
  options.name = 'dgplvm';
  options.initX = zeros(2,size(X_init,2));
  options.initX(1,:) = true;
  options.initX(2,:) = false;
  
  model = sgplvmCreate(model,[],options);
  
  % add discriminative constraints
  options_constraint = constraintOptions('LDA');
  options_constraint.class = zeros(model.N,1);
  options_constraint.N = model.N;
  options_constraint.q = model.q;
  options_constraint.class(1:1) = 2;
  %options_constraint.class(30:50) = 3;
  options_constraint.dim = 1;%:1:model.q;
  options_constraint.lambda = 1e6;
  model = sgplvmAddConstraint(model,options_constraint);
  
  options_constraint.dim = 1:2:model.q;
  options_constraint.class(2:1:5) = 3;
  %model = sgplvmAddConstraint(model,options_constraint);

  data_type = 'tulou';
 otherwise
  error('Unkown SGPLVM Type');
end

% 5. Train SGPLVM model
model = sgplvmOptimise(model,true,nr_iters,false,false);

switch data_type
 case 'human'
   switch sgplvm_model_type
     case 'mlmi2008'
       sgplvmVisualise(model,[],'xyzankurVisualise','xyzankurModify', ...
		  Y_train([2 9],:),'ncca12',100,Z_train([2 9],:));
     otherwise

   end
 otherwise
  
end


keep('model');
