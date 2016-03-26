
----------------------------- getMapCellsFromRay.cpp 

[ x_between, y_between] = getMapCellsFromRay(x_start,y_start, x_end, y_end);
 
INPUT:  
x/y_start     the current center of lidar scanning [int]. 
x/y_end       the lidar reading, that is an occupied or occluding cell [double].
 
OUTPUT: 
x/y_between   the indices of cells in between the starting and ending points, including the starting point.
 
Note:
- input arguments can be in the vector form (for example, getMapCellsFromRay([0 0],[0 1],[10 9],[5 6]); )
- the output indices may include repeated ones. 
- getMapCellsFromRay(0,0.99,10,5); and getMapCellsFromRay(0,0,10,5); return the same result
  (First two arguments are integers and the last two are doubles) 


----------------------------- map_correlation.cpp

c = map_correlation(map,x_im,y_im,X,x_range,y_range)

INPUT: 
map               the map [char]
x_im,y_im         physical x,y positions of the grid map cells [double] 
X                 occupied x,y positions from range sensor (in physical unit) [double]
x_range,y_range   physical x,y positions you want to evaluate "correlation" [double]

OUTPUT: 
c                 sum of the cell values of all the positions hit by range sensor [double]


Note:
- map must be BYTE (char or int8)
- other input arguments must be double. 
- X must be in this form: X = [x; y; z] where x, y are row vectors and z is some dummy values. 
