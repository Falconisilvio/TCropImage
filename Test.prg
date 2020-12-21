 
 * MIT License
* 
* Copyright (c) 2018 Silvio Falconi 
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
 
 
 
 
 
 #include "Fivewin.ch"
 #include "Constant.ch"


// test for crop an Image
// see the TCropImage Class at the End


 static oImage,oImagePreview,oImageCropped
 static nWBmp,nHBmp,oGroupCropped,oGroupPreview

 Function Test()

   Local oDlg
   Local nBottom   := 31
   Local nRight    := 115
   Local nWidth :=  Max( nRight * DLG_CHARPIX_W, 180 )
   Local nHeight := nBottom * DLG_CHARPIX_H
   Local oCursorBtn :=TCursor():New(,'HAND')
   Local aGet[1]
   Local cImage


    nWBmp   := 0
    nHBmp   := 0

 DEFINE DIALOG oDlg  ;
   TITLE "Crop an image"    ;
   SIZE nWidth, nHeight TRANSPARENT PIXEL



     * @ 0, 0 IMAGE oImage SIZE 280, 200 OF oDlg SCROLL NOBORDER

       oImage:= TCropImage():New( 0, 0, 280, 200,,, .t.,oDlg,,, .t.,,,,,,,,,,)

      //Image Preview
        @ 120, 330 IMAGE oImagePreview SIZE 80, 80 OF oDlg ADJUST  PIXEL NOBORDER
        @ 110,320   GROUP oGroupPreview   TO 205,420 PIXEL OF oDlg



        //image Cropped
        @ 20, 330 IMAGE oImageCropped SIZE 80, 80 OF oDlg  PIXEL NOBORDER //ADJUST
        @ 10,320  GROUP oGroupCropped   TO 105,420 PIXEL OF oDlg




  @ 215, 8 SAY "File :" SIZE 55,18 PIXEL OF oDlg

  @ 210,30 GET aGet[1] VAR cImage SIZE 250,18 PIXEL OF oDlg

  @ 210,280 button "Select" action  (cImage:= GetImage(),aGet[1]:refresh()) SIZE 42,17 PIXEL OF oDlg

  @ 210,390 button "Exit" SIZE 42,17 PIXEL OF oDlg action  oDlg:End()



ACTIVATE DIALOG  oDlg CENTERED

RETURN NIL

//---------------------------------------------------------------------------------------//

function GetImage()

   local gcFile := cGetFile( "Bitmap (*.bmp)| *.bmp|" +         ;
                             "DIB   (*.dib)| *.dib|" +          ;
                             "PCX   (*.pcx)| *.pcx|"  +         ;
                             "JPEG  (*.jpg)| *.jpg|" +          ;
                             "GIF   (*.gif)| *.gif|"  +         ;
                             "TARGA (*.tga)| *.tga|" +          ;
                             "RLE   (*.rle)| *.rle|" +          ;
                             "All Files (*.*)| *.*"             ;
                            ,"Please select a image file", 4 )

   if ! Empty( gcFile ) .and. File( gcFile )
      oImage:LoadBmp( gcFile )
      oImagePreview:LoadBmp( gcFile )



        nWBmp   := alltrim(str(nBmpWidth( oImage:hBitmap )))
        nHBmp   := alltrim(str(nBmpHeight( oImage:hBitmap ) ))


        oGroupPreview:setText("Image Preview: Dim. "+nWBmp+"X"+nHBmp )


         oGroupPreview:refresh()






endif

return gcFile

//---------------------------------------------------------------------------------------//

CLASS TCropImage FROM TImage

   DATA nBoxTop
   DATA nBoxLeft
   DATA nBoxBottom
   DATA nBoxRight
   DATA lBoxDraw

    CLASSDATA lRegistered AS LOGICAL


   METHOD New( nTop, nLeft, nWidth, nHeight, cResName, cBmpFile, lNoBorder,;
               oWnd, bLClicked, bRClicked, lScroll, lStretch, oCursor,;
               cMsg, lUpdate, bWhen, lPixel, bValid, lDesign, cVarName ) CONSTRUCTOR

    METHOD LButtonDown( nRow, nCol, nFlags )
    METHOD MouseMove( nRow, nCol, nFlags )
    METHOD LButtonUp( nRow, nCol, nFlags )
    METHOD DrawBox()

ENDCLASS
//------------------------------------------------------------------------------------//

   METHOD New( nTop, nLeft, nWidth, nHeight, cResName, cBmpFile, lNoBorder,;
            oWnd, bLClicked, bRClicked, lScroll, lStretch, oCursor,;
            cMsg, lUpdate, bWhen, lPixel, bValid, lDesign, cVarName ) CLASS TCropImage


   ::Super:New( nTop, nLeft, nWidth, nHeight, cResName, cBmpFile, lNoBorder, ;
              oWnd, bLClicked, bRClicked, lScroll, lStretch, oCursor,      ;
              cMsg, lUpdate, bWhen, lPixel, bValid, lDesign )



   ::lBoxDraw:=.f.
   ::nBoxTop:=0
   ::nBoxLeft:=0
   ::nBoxBottom := 0
   ::nBoxRight  := 0

    return Self

//-------------------------------------------------------------------------------//
 METHOD LButtonDown( nRow, nCol, nFlags ) CLASS TCropImage

    if ::bLClicked != nil
        Eval( ::bLClicked, nRow, nCol, nFlags )
     else

        ::lBoxDraw   := .t.

        ::nBoxTop    :=  nRow
        ::nBoxLeft   :=  nCol

        ::Capture()
        ::DrawBox()    //deletes existing dottedbox


    endif

    return ::Super:LButtonDown( nRow, nCol, nFlags )

//-------------------------------------------------------------------------------//
   METHOD MouseMove( nRow, nCol, nFlags ) CLASS TCropImage



    if ::lBoxDraw
        ::DrawBox()     //deletes existing dottedbox


          ::nBoxBottom := nRow
          ::nBoxRight  := nCol

        ::DrawBox()     //redraws new dottedbox

    endif

return ::Super:MouseMove( nRow, nCol, nFlags )

//-------------------------------------------------------------------------------//
 METHOD LButtonUp( nRow, nCol, nFlags ) CLASS TCropImage



   if ::lBoxDraw .and. ::nBoxTop <> ::nBoxBottom .and. ::nBoxLeft <> ::nBoxRight

      ::DrawBox()

        ReleaseCapture()

        DrawFocusRect( ::hdc, { ::nBoxTop, ::nBoxLeft, ::nboxBottom, ::nBoxRight } )

        ::ScrollAdjust()


        ::refresh( .t. )

           Msginfo( "ntop ="+STR(::nBoxTop)+CRLF+      ;
                    "nLeft ="+STR(::nBoxLeft)+CRLF+    ;
                    "nBottom ="+STR(::nBoxBottom)+CRLF+;
                    "nRight ="+STR(::nBoxRight)              )


         CutImage(::nBoxTop, ::nBoxLeft, ::nboxBottom, ::nBoxRight)

    endif

    ::lBoxDraw = .f.

return ::Super:LButtonUp( nRow, nCol, nFlags )

//-------------------------------------------------------------------------------//

 METHOD DrawBox() CLASS TCropImage

    RectDotted( ::hWnd, ::nBoxTop, ::nBoxLeft, ::nBoxBottom, ::nBoxRight )

Return Nil

//-------------------------------------------------------------------------------//


Function  CutImage(nBoxTop,nBoxLeft,nBoxBottom,nBoxRight)
   local nType:= 2 //jpg
   Local cNameFileCropped:="cropped.jpg"
   Local nWBmp,nHBmp

    oImageCropped:hBitmap:=  CropImage( oImage:hBitmap,nBoxTop,nBoxLeft, nBoxBottom, nBoxRight)
    oImageCropped:SaveImage( cNameFileCropped, nType)
    oImageCropped:LoadBmp( cNameFileCropped )

        nWBmp   := alltrim(str(nBmpWidth( oImageCropped:hBitmap )))
        nHBmp   := alltrim(str(nBmpHeight( oImageCropped:hBitmap ) ))


        oGroupCropped:setText("Image Cropped : Dim. "+nWBmp+"X"+nHBmp )
        oGroupCropped:refresh()




  return nil




//-------------------------------------------------------------------------------//
#pragma BEGINDUMP

#include <hbapi.h>
#include <windows.h>

HB_FUNC( CROPIMAGE ) //hOriginalBmp, nTop, nLeft, nBottom, nRight --> hCroppedBmp
{
   HDC hdc1, hdcSrc, hdcDest;
   HBITMAP hbmpSrc  = ( HBITMAP ) hb_parnl( 1 );
   HBITMAP hbmpDest, hold1, hold2;
   RECT rct;
   BITMAP bm;

   GetObject( ( HGDIOBJ ) hbmpSrc, sizeof( BITMAP ), ( LPSTR ) &bm );

   rct.top    = hb_pcount() > 1 ? hb_parnl( 2 ) : 0;
   rct.left   = hb_pcount() > 2 ? hb_parnl( 3 ) : 0;
   rct.bottom = hb_pcount() > 3 ? hb_parnl( 4 ) : bm.bmHeight;
   rct.right  = hb_pcount() > 4 ? hb_parnl( 5 ) : bm.bmWidth;


   hdc1 = GetDC( GetDesktopWindow() );
   hdcSrc = CreateCompatibleDC( hdc1 );
   hdcDest = CreateCompatibleDC( hdc1 );

   hbmpDest = CreateCompatibleBitmap( hdc1, rct.right - rct.left, rct.bottom - rct.top );

   ReleaseDC( GetDesktopWindow(), hdc1 );

   hold1 = SelectObject( hdcSrc, hbmpSrc );
   hold2 = SelectObject( hdcDest, hbmpDest );

   BitBlt( hdcDest, 0, 0, rct.right, rct.bottom, hdcSrc, rct.left, rct.top, SRCCOPY );

   SelectObject( hdcSrc, hold1 );
   SelectObject( hdcDest, hold2 );

   DeleteDC( hdcSrc );
   DeleteDC( hdcDest );

   hb_retnl( ( LONG ) hbmpDest );

}
#pragma ENDDUMP
