#include "math.h"
#include "mex.h"
#include "matrix.h"
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include "agg_basics.h"
#include "agg_pixfmt_rgb.h"
#include "agg_renderer_base.h"
#include "agg_font_freetype.h"
#include "agg_renderer_scanline.h"
#include "agg_font_cache_manager.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double *textString=mxGetPr(prhs[0]);
    double *backgroundColor=mxGetPr(prhs[1]);
    double *foregroundColor=mxGetPr(prhs[2]);
    const char *fontName=mxArrayToString(prhs[3]);
    double *fontSize=mxGetPr(prhs[4]);
    mwSignedIndex  dims[3];
    double xPos;
    int stringPosition, image_height, image_width,minY,maxY,genericIndex1,genericIndex2,genericIndex3;
    const agg::glyph_cache *glyph;
   
    typedef agg::pixfmt_rgb24 pixfmt_type;
    typedef agg::renderer_base<pixfmt_type> ren_base_type;
    typedef agg::renderer_scanline_aa_solid<ren_base_type> renderer_solid_type;
    typedef agg::font_engine_freetype_int32 font_engine_type;
    typedef agg::font_cache_manager<font_engine_type> font_manager_type;

    font_engine_type m_feng;
    font_manager_type m_fman(m_feng);

    m_feng.load_font(fontName,0,agg::glyph_ren_native_gray8);
    m_feng.width(*fontSize);
    m_feng.height(*fontSize);
    m_feng.hinting(true);
    stringPosition=0;
    image_height=*fontSize;
    image_width=0;
    xPos=0.0;
    minY=INT_MAX;
    maxY=INT_MIN;
    while(*(textString+stringPosition))
      {        
	glyph=m_fman.glyph(*(textString+stringPosition));
    if ((*(textString+stringPosition)!=32) && (glyph->bounds.y1<minY))
        minY=glyph->bounds.y1;
    if ((*(textString+stringPosition)!=32) && (glyph->bounds.y2>maxY))
        maxY=glyph->bounds.y2;
    
	xPos+=glyph->advance_x;
	stringPosition++;
      }
    if (*fontSize<(double)(maxY-minY))
        image_height=maxY-minY;
    image_width=ceil(xPos);
    
    unsigned char *buffer = new unsigned char[image_height*image_width*3];
    agg::rendering_buffer rbuf(buffer,image_width,image_height,-image_width*3);
    pixfmt_type pixf(rbuf);
    ren_base_type ren_base(pixf);
    ren_base.clear(agg::rgba(*backgroundColor/255, *(backgroundColor+1)/255, *(backgroundColor+2)/255));
    renderer_solid_type ren_solid(ren_base);
    ren_solid.color(agg::rgba8(*foregroundColor,*(foregroundColor+1),*(foregroundColor+2)));
    
    stringPosition=0;
    xPos=0.0;
    while(*(textString+stringPosition))
      {
	glyph=m_fman.glyph(*(textString+stringPosition));
    m_fman.init_embedded_adaptors(glyph, xPos, -minY+(image_height-(maxY-minY))/2);

    
	agg::render_scanlines(m_fman.gray8_adaptor(),m_fman.gray8_scanline(),ren_solid);
	xPos+=glyph->advance_x;
	stringPosition++;
      }
    
    dims[0]=(mwSignedIndex)image_height;
    dims[1]=(mwSignedIndex)image_width;
    dims[2]=3;
    
    unsigned char *bufferPermuted = new unsigned char[image_height*image_width*3];    
    for (genericIndex1=0;genericIndex1<3;genericIndex1++)
        for (genericIndex2=0;genericIndex2<image_width;genericIndex2++)
            for (genericIndex3=0;genericIndex3<image_height;genericIndex3++)
                *(bufferPermuted+genericIndex1*image_width*image_height+genericIndex2*image_height+genericIndex3)=*(buffer+genericIndex3*image_width*3+genericIndex2*3+genericIndex1);
    
    plhs[0] = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
    memcpy(mxGetPr(plhs[0]), bufferPermuted, dims[0]*dims[1]*dims[2]);
    delete buffer;
    delete bufferPermuted;
}
