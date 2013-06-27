function out = nccaOut(model,X,type,nr_nn,iters,balancing,opt_type,unique_ratio)

% NCCAOUT Evaluate the output of an NCCA model.
% FORMAT
% DESC Y = nccaOut(model, x, type, ..) evaluates the output of a
% given NCCA model
% ARG model : the model for which the output is being evaluated.
% ARG x : the input position for which the output is required.
% ARG type : inference type
% 'YtoX' evaluate the latent cordinates from input Y
% 'ZtoX' evaluate the latent cordinates from input Z
% 'YtoZ' evaluate the corrsponding observations to Y
% 'ZtoY' evaluate the corrsponding observations to Z
% 'YtoXdyn' disambiguate the latent cordinates from  Y using
% dynamics
% 'ZtoXdyn' disambiguate the latent cordinates from Z using
% dynamics
% 'YtoZdyn' disambiguate the corresponding observations from Y
% using dynamics
% 'ZtoYdyn' disambiguate the corresponding observations from Z
% using dynamics
% ARG P1, P2,... : optional arguments to be passed
% RETURN : output of chose type
%
% SEEALSO : nccaCreate
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

if(nargin<8)
  unique_ratio = 0;
  if(nargin<7)
    opt_type = 'all';
    if(nargin<6)
      balancing = 1;
      if(nargin<5)
	iters = 100;
	if(nargin<4)
	  nr_nn = 8;
	  if(nargin<3)
	    if(model.fy.d==size(X,2))
	      type = 'YtoZ';
	    else
	      type = 'ZtoY';
	    end
	    if(nargin<2)
	      error('To Few Arguments');
	    end
	  end
	end
      end
    end
  end
end

if(~strcmp(model.type,'ncca'))
  error('Wrong Model Type');
end

switch type
 case {'YtoZ','YtoX','YtoXdyn','YtoZdyn'}
  Y = X; clear X;
  X = nccaComputeModes(model.gy,model.fz,Y,nr_nn,true,iters);
  X = nccaSortModes(model.fz,X);
  %X = nccaRemoveMultipleModes(model.fz,X,unique_ratio);
  switch type
   case 'YtoX'
    X = nccaRemoveMultipleModes(model.fz,X,unique_ratio);
    out = X;
    return;
   case 'YtoZ'
    X = nccaRemoveMultipleModes(model.fz,X,unique_ratio);
    for(i = 1:1:size(X,1));
      out{i} = modelOut(model.fz,X{i});
    end
    return
   case {'YtoZdyn','YtoXdyn'}
    if(isfield(model,'dyn_z')&&~isempty(model.dyn_z))
      X = nccaComputeViterbiPath(model.gy,model.fz,model.dyn_z,X,Y,balancing,true);
      switch opt_type
       case 'independent'
      	X = nccaSequenceOptimise(model.gy,model.fz,model.dyn_z,X,'independent',iters,balancing,true);
       case 'all'
	fprintf('Using dynamic model over full latent space\n');
	X = nccaSequenceOptimise(model.gy,model.fz,model.dyn_z,X,'all',iters,balancing,true);
       otherwise
	warning('Unkown Optimisation Type, returning modes');
	out = X;
	return;
      end
	
      switch type
       case 'YtoXdyn'
	out = X;
	return
       case 'YtoZdyn'
	out = modelOut(model.fz,X);
	return
      end
    else
      warning('No Dynamical Model Given: Returning Modes');
      out = X;
      return
    end
  end
 case {'ZtoY','ZtoX','ZtoXdyn','ZtoYdyn'}
  Z = X;clear X;
  X = nccaComputeModes(model.gz,model.fy,Z,nr_nn,true);
  X = nccaSortModes(model.fy,X);
  %X = nccaRemoveMultipleModes(model.fy,X,unique_ratio);
  switch type
   case 'ZtoX'
    out = X;
    X = nccaRemoveMultipleModes(model.fy,X,unique_ratio);
    return
   case 'ZtoY'
    X = nccaRemoveMultipleModes(model.fy,X,unique_ratio);
    for(i = 1:1:size(X,1))
      out{i} = modelOut(model.fy,X{i});
    end
    return
   case {'ZtoXdyn','ZtoYdyn'}
    if(isfield(model,'dyn_y')&&~isempty(model.dyn_y))
      X = nccaComputeViterbiPath(model.gz,model.fy,model.dyn_y,X,Z,balancing,true);
      switch opt_type
       case 'independent'
	X = nccaSequenceOptimise(model.gz,model.fy,model.dyn_y,X,'independent',iters,balancing,true);
       case 'all'
	X = nccaSequenceOptimise(model.gz,model.fy,model.dyn_y,X,'all',iters,balancing,true);
       otherwise
	warning('Unknown Optimisation Type, returning modes');
	out = X;
	return;
      end
      switch type
	
       case 'ZtoXdyn'
	out = X;
	return
       case 'ZtoYdyn'
	out = modelOut(model.fy,X);
	return
      end
    else
      warning('No Dynamical Model Give: Returning Modes');
      out = X;
      return
    end
  end
 otherwise
  error('Unkown Type');
end




