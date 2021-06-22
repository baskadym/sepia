% [totalField, N_std, headerAndExtraData] = Wrapper_EchoCombine_OptimumWeight(fieldMap,mask,matrixSize,voxelSize,algorParam,headerAndExtraData)
%
% Input
% --------------
% fieldMap      : original single-/multi-echo wrapped phase image, in rad
% mask          : signal mask
% matrixSize    : size of the input image
% voxelSize     : spatial resolution of each dimension of the data, in mm
% algorParam    : structure contains fields with algorithm-specific parameter(s)
% headerAndExtraData : structure contains extra header info/data for the algorithm
%
% Output
% --------------
% totalField    : unwrapped total field, in radHz
% N_std         : noise standard deviation in the field map
% fieldmapUnwrapAllEchoes : unwrapped echo phase, in rad
%
% Description: Wrapper to perform phase echo combination
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 22 June 2021 (v1.0)
% Date modified:
%
%
function [totalField, N_std, headerAndExtraData] = Wrapper_EchoCombine_OptimumWeight(fieldMap,mask,matrixSize,voxelSize,algorParam,headerAndExtraData)

% get some data from headerAndExtraData
magn	= double(headerAndExtraData.magn);
TE      = headerAndExtraData.te;

% initiate empty variable
fieldmapUnwrapAllEchoes = [];

% check if the input data multiecho or not
isMultiecho = size(fieldMap,4) > 1;
% find the centre of mass
pos=round(centerofmass(magn(:,:,:,1)));

if isMultiecho
    
%%%%%%%%%%%%%%%%%%%%%%%% Multi-echo %%%%%%%%%%%%%%%%%%%%%%%%
    % compute wrapped phase shift between successive echoes
    fieldMapEchoTemp = angle(exp(1i*fieldMap(:,:,:,2:end))./exp(1i*fieldMap(:,:,:,1:end-1)));

    % unwrap each echo phase shift
    tmp2             = zeros(size(fieldMapEchoTemp),'like',fieldMap);
    for k = 1:size(fieldMapEchoTemp,4)
        fprintf('Unwrapping #%i echo shift...\n',k);
        tmp           = UnwrapPhaseMacro(fieldMapEchoTemp(:,:,:,k),mask,matrixSize,voxelSize,algorParam,headerAndExtraData);
        tmp2(:,:,:,k) = tmp-round(tmp(pos(1),pos(2),pos(3))/(2*pi))*2*pi;
    end

    % get phase accumulation over all echoes
    phaseShiftUnwrapAllEchoes = cumsum(tmp2,4);    

    % compute unwrapped phase shift between successive echoes
    fieldMapUnwrap = zeros(size(phaseShiftUnwrapAllEchoes),'like',fieldMap);
    for k = 1:size(phaseShiftUnwrapAllEchoes,4)
        fieldMapUnwrap(:,:,:,k) = phaseShiftUnwrapAllEchoes(:,:,:,k)/(TE(k+1)-TE(1));
    end

    % Robinson et al. 2017 NMR Biomed Appendix A2
    fieldMapSD = zeros(size(phaseShiftUnwrapAllEchoes),'like',fieldMap);
    for k=1:size(phaseShiftUnwrapAllEchoes,4)
        fieldMapSD(:,:,:,k) = 1./(TE(k+1)-TE(1)) ...
            * sqrt((magn(:,:,:,1).^2+magn(:,:,:,k+1).^2)./((magn(:,:,:,1).*magn(:,:,:,k+1)).^2));
    end

    % weights are inverse of the field map variance
    weight = bsxfun(@rdivide,1/(fieldMapSD.^2),sum(1/(fieldMapSD.^2),4));

    % Weighted average of unwrapped phase shift
    totalField                    = sum(fieldMapUnwrap .* weight,4);
    totalField(isnan(totalField)) = 0;
    totalField(isinf(totalField)) = 0;

    % standard deviation of field map from weighted avearging
    totalFieldVariance                  = sum(weight.^2 .* fieldMapSD.^2,4);
    totalFieldSD                        = sqrt(totalFieldVariance);
    totalFieldSD(isnan(totalFieldSD))   = 0;
    totalFieldSD(isinf(totalFieldSD))   = 0;
    totalFieldSD                        = totalFieldSD./norm(totalFieldSD(mask~=0));

    % get the unwrapped phase accumulation across echoes
    % unwrap first echo
    tmp                     = UnwrapPhaseMacro(fieldMap(:,:,:,1),mask,matrixSize,voxelSize,algorParam,headerAndExtraData);
%     tmp                     = tmp-round(tmp(pos(1),pos(2),pos(3))/(2*pi))*2*pi;
    tmp                     = tmp-round(mean(tmp( mask == 1))/(2*pi))*2*pi;
    fieldmapUnwrapAllEchoes = cat(4,tmp,tmp2);
    fieldmapUnwrapAllEchoes = cumsum(fieldmapUnwrapAllEchoes,4);

else

%%%%%%%%%%%%%%%%%%%%%%%% Single echo %%%%%%%%%%%%%%%%%%%%%%%%
    tmp                                 = UnwrapPhaseMacro(fieldMap,mask,matrixSize,voxelSize,algorParam,headerAndExtraData);
%     tmp                     = tmp-round(tmp(pos(1),pos(2),pos(3))/(2*pi))*2*pi;
    tmp                                 = tmp-round(mean(tmp( mask == 1))/(2*pi))*2*pi;
    totalField                          = tmp/(TE(1));
    totalFieldSD                        = 1./magn;
    totalFieldSD(isnan(totalFieldSD))   = 0;
    totalFieldSD(isinf(totalFieldSD))   = 0;
    totalFieldSD                        = totalFieldSD./norm(totalFieldSD(mask~=0));
end

N_std = totalFieldSD;

% apply mask
totalField              = bsxfun(@times,totalField,mask);
N_std                   = bsxfun(@times,N_std,mask);
fieldmapUnwrapAllEchoes = bsxfun(@times,fieldmapUnwrapAllEchoes,mask);

if ~isempty(fieldmapUnwrapAllEchoes)
    headerAndExtraData.fieldmapUnwrapAllEchoes = fieldmapUnwrapAllEchoes;
end

end
