function img = padim(img, sz)
   % Enlarges an image to the size of the screen. 
   % Does nothing is given new size is smaller than image
   % in that dimension.
   %
   % Parameters
   % - img, 2D matrix to be enlarged.
   % - sz, Size of image to be enlarged to.

   assert(length(size(img))==2, 'Image must be 2D.')
   assert(length(size(sz))==2, 'New size must be 2D.')
   padding= [0,0];
   if size(img,1)<sz(1) 
      padding(1)= ceil((sz(1)-size(img,1))/2);
   end
   if size(img,2)<sz(2)
      padding(2)= ceil((sz(2)-size(img,2))/2);
   end   
   img= padarray(img,padding,0,'both');
end