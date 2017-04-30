function im = colorindex(im,bins,imin,imax)
icell = (imax - imin + 1)/bins;
im = max(min(ceil((im-imin) / icell),bins),1)-1;