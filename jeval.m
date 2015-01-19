function jeval( fstr,varargin )
    feval(str2func(fstr),varargin{:});
end