// Copyright (c) 2015 Andrew Glassner and Eric Haines
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// This routine writes an STL file one facet at a time. It uses the BinaryWriter for efficiency.

import java.io.File;
import java.io.RandomAccessFile;
import java.io.IOException;

class STLWriter extends BinaryWriter {

  int facetCount;
  String filePath;

  /*
  Open a file for writing. The filename is relative to the sketch directory.
  To get the bytes of integers and floats to be written in reverse order (needed
  for the STL format which demands little-endian numbers), set the flag to true. 
  */
  STLWriter(String _filename, boolean _reverseBytes) {
    /* 
    These first two lines are a little weird. I want to save the absolute path to the
    file as returned by savePath(), but Processing requires that the very first
    call of a subclass constructor be to the superclass' constructor. So I find the
    path inside the call to the super constructor, then do it again to save it. Sigh.
    I first used sketchPath(), but savePath() is better here because it will create any
    needed directories (e.g., if the filename is "data/files/newshape.STL" then it
    will create the directories data and data/files if required. Note that
    as far as I can tell, savePath() (like sketchPath()) is undocumented. Yet from the
    comments in the Processing 3 source code, it's clearly supported. Go figure.
    */  
    super(savePath(_filename), _reverseBytes);
    filePath = savePath(_filename); // undocumented Processing function! 
    byte[] byteArray = new byte[84];  // 80 for the header + 4 for facetCount
    for (int i=0; i<byteArray.length; i++) byteArray[i] = 0;  // header is all 0
    writeByteArray(byteArray);
    facetCount = 0;
  }

  // write a facet to the output file
  void writeFacet(PVector n, PVector v0, PVector v1, PVector v2) {
    writePVector(n);
    writePVector(v0);
    writePVector(v1);
    writePVector(v2);
    byte[] spacer = new byte[2];
    spacer[0] = spacer[1] = 0;
    writeByteArray(spacer);
    facetCount++;
  }

  // write this PVector to the output file
  void writePVector(PVector v) {
    writeFloat(v.x);
    writeFloat(v.y);
    writeFloat(v.z);
  }

  /*
  The facet count is an integer in the first 4 bytes after the opening 80-byte header.
  Usually, we only know that value after we're done writing the facets, so the last 
  thing to do before closing the file would be seek back near the start and write the value.
  Unfortunately, I don't know how to randomly seek inside the file streams I'm using,
  so I'll close the file, re-open it, over-write those four bytes, and close it again.
  It's hardly a wonderful solution, but it does the job and only has to happen once
  per file, so for now I'm okay with it.
  */
  void close() {
    super.close();
    try {
      File file = new File(filePath);
      RandomAccessFile raf = new RandomAccessFile(file, "rw");
      raf.seek(80);  // skip the 80-byte header
      byte[] facetCountAsBytes = new byte[4];
      intToBytes(facetCount, facetCountAsBytes);
      raf.write(facetCountAsBytes, 0, 4);
      raf.close();
    } 
    catch (IOException e) {
      System.out.println("STLWriter close: IOException:" + e);
      e.printStackTrace();
    }
  }
}

