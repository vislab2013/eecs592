% Set up global paths used throughout the code
addpath 20120515-pose-release-ver1.3/code-full/;
addpath 20120515-pose-release-ver1.3/code-full/learning/;
addpath 20120515-pose-release-ver1.3/code-full/detection/;
addpath 20120515-pose-release-ver1.3/code-full/visualization/;
addpath 20120515-pose-release-ver1.3/code-full/evaluation/;
if isunix()
  addpath 20120515-pose-release-ver1.3/code-full/mex_unix/;
elseif ispc()
  addpath 20120515-pose-release-ver1.3/code-full/mex_pc/;
end

% directory for caching models, intermediate data, and results
cachedir = 'cache/';
if ~exist(cachedir,'dir')
  mkdir(cachedir);
end

if ~exist([cachedir 'imrotate/'],'dir')
  mkdir([cachedir 'imrotate/']);
end

if ~exist([cachedir 'imflip/'],'dir')
  mkdir([cachedir 'imflip/']);
end

% addpath BUFFY;
