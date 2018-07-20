function [html] = printHTMLImageInput(urlidx)
%printHTMLImageInput Print HTML for displaying image from given url
%   Detailed explanation goes here

baseHtml_ch = ['<div class="col-xs-12 col-sm-8 image"><img alt="image_url" '...
    'class="img-responsive center-block" src="${image_url}" /></div>'];
imageUrl_ch = strcat('image', nu2mstr(urlidx), '_url');
html = { strrep(baseHtml_ch, 'image_url', imageUrl_ch) };
end