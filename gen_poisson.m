function [ times ] = gen_poisson( rateFn, intrvl, varargin )
%SUMMARY: This function generates a trajectory of a nonhomogeneous Poisson
%process over the specified interval.
%   DETAILS:
%       rateFn = function handle
%       intrvl = interval over which to inspect process e.g. [0,5]
%       NOTES: Type 'plot' as argument for plotting.

%% Init Stuff
% only want 1 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 1
    error('NonHomPoisson:TooManyInputs', ...
        'requires at most 1 optional inputs');
end

% set defaults for optional inputs
optargs = {'noplot'};
for i=1:length(varargin)
    if strcmp(varargin(i),'plot')
        optargs(1) = varargin(i);
    end
end

% Place optional args in memorable variable names
[plotvar] = optargs{:};

%% Generate Process Realization
%Determine a majorizing rate r and generate a homogeneous poisson process
%on the interval [0,intrvl]
temp = @(x) -rateFn(x);
r = rateFn(fminbnd(temp,intrvl(1),intrvl(2)));
% disp(strcat('majorizing rate r =',num2str(r)))

% Determine majorizing poison process event times
tempTimes = 0;
while tempTimes(length(tempTimes))<=intrvl(2);
    % Generate time of next transition as Poisson
    u = rand;
    tempTimes(length(tempTimes)+1) = tempTimes(length(tempTimes))-log(u)/r;
end
% disp('tempTimes = ')
% disp(tempTimes)

times = [];
% Thin maj. PP event times accordingly. Only run to 2nd to last item in
% tempTimes since the last one is the one which violates lying in the
% interval. Start at i=2 to ignore tempTimes(1) = 0 which was a crutch for
% computing.
for i=2:length(tempTimes)-1
    v = rand;
%    disp(strcat('v =',num2str(v)))
%    disp(strcat('rateFn(tempTime)/10 = ',num2str(rateFn(tempTimes(i))/r)))
    if and(rateFn(tempTimes(i)) >= 0, v <= rateFn(tempTimes(i))/r)
        times(length(times)+1) = tempTimes(i);
%        disp('pass')
    else
%        disp('rej')
    end
%    disp('--------------------------------------------------------')
end

% disp('times = ')
% disp(times)

if and(not(times>1),strcmp('plot',plotvar));
    disp('Note, times has either 1 or 0 elements, hence no plot is produced')
end

%% Output Spec Handling
if and(strcmp(plotvar,'plot'),length(times)>1)
    plot(times(1,:),ones(1,length(times)),'or');
    axis([0,intrvl(2),0,2])
end

end

