function tic_print( string )

persistent th;

if isempty(th)
  th = tic();
end

if toc(th) > 1
  fprintf(string);
  drawnow;
  th = tic();
end

end