function img = cropim(img, sz)
   % Crops an image to the size of the screen. 
   % Does nothing is given new size is larger than image
   % in that dimension.
   %
   % Parameters
   % - img, 2D matrix to be cropped.
   % - sz, Size of image to be cropped to.

    assert(length(size(img))==2, 'Image must be 2D.')
    assert(length(size(sz))==2, 'New size must be 2D.')
    if size(img,1)>sz(1)
        diff= ceil((size(img,1)-sz(1))/2);
        img = img(diff+1:diff+sz(1),:);
    end
    if size(img,2)>sz(2)
        diff= ceil((size(img,2)-sz(2))/2);
        img = img(:,diff+1:diff+sz(2));
    end
end 