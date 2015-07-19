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

/*
These routines allow us to write big binary files efficiently by using an internal buffer.
We can also reverse the order of the bytes in each floating-point word to accommodate the
STL standard (which has an undocumented but required need to be little-endian
(see http://en.wikipedia.org/wiki/STL_%28file_format%29)
*/

import java.io.DataOutputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.io.*;

boolean TempErrorWritten = false;

class BinaryWriter {

  String pathName;
  boolean reverseBytes;
  FileOutputStream fstream;
  BufferedOutputStream bstream;
  DataOutputStream dstream;
  ByteBuffer bb = ByteBuffer.allocate(4);
  byte[] b4, localBuffer;
  int localBufferIndex;

  /*
  Open a file at the absolute path handed in _pathName. Before writing
  integers and floats, the bytes will be reversed if the boolean is set to true.
  This is to accommodate file formats that demand an order that is not native to
  the computer the sketch is running on. This is very operating-system dependent.
  */
  BinaryWriter(String _pathName, boolean _reverseBytes) {
    //println("New BinaryWriter at minutes="+minute()+" seconds="+second());
    reverseBytes = _reverseBytes;
    pathName = _pathName;
    dstream = null;
    bstream = null;
    fstream = null;
    bb = ByteBuffer.allocate(4);
    localBuffer = new byte[10000];  // arbitrarily-sized "big" buffer
    localBufferIndex = 0;
  }
  
  void openFiles() {
    try {
      fstream = new FileOutputStream(pathName, false);  // a new file, don't append
      bstream = new BufferedOutputStream(fstream);
      dstream = new DataOutputStream(bstream);
    }
    catch(IOException e) {
      println("BinaryWriter constructor: IOException:" + e);
    }
  }
  
  // flush the file, then close it
  void close() {
    try {
      flush();
      // close all file streams, then set them to null to prevent using stale pointers
      dstream.close();
      bstream.close();
      fstream.close();
      dstream = null;
      bstream = null;
      fstream = null;
    }
    catch(IOException e) {
      println("BinaryWriter close: IOException:" + e);
    }
  }
  
  // flush whatever's in the buffer and reset the buffer index
  void flush() {
    int ilb = localBufferIndex;
    if (dstream == null) {
      openFiles();
    }
    try {
      if (localBufferIndex > 0) {
        dstream.write(localBuffer, 0, localBufferIndex);
      }
      dstream.flush();
      localBufferIndex = 0;
    }
    catch(IOException e) {
      println("BinaryWriter flush: IOException:" + e+" incoming localBufferIndex="+ilb+" and now="+localBufferIndex);
      if (dstream == null) println("dstream is null"); else println("dstream is not null, ="+dstream);
      println("localBuffer.length = "+localBuffer.length);
    }
  }
  
  // if we're close to to end of the buffer, flush it
  void testFlush() {
    if (localBufferIndex > localBuffer.length - 110) { // each facet takes 50 bytes
      flush();
    }
  }
  
  // flush if we're getting full, then queue up this array of bytes for output
  void appendToBuffer(byte[] b) {
    assert localBufferIndex < localBuffer.length : "#1: localBufferIndex="+localBufferIndex+" and localBuffer.length="+localBuffer.length;
    testFlush();
    assert localBufferIndex < localBuffer.length : "#2: localBufferIndex="+localBufferIndex+" and localBuffer.length="+localBuffer.length;
    for (int i=0; i<b.length; i++) {
      localBuffer[localBufferIndex++] = b[i];
    }
    assert localBufferIndex < localBuffer.length : "#3: localBufferIndex="+localBufferIndex+" and localBuffer.length="+localBuffer.length;
  }
  
  // assumes we have a 4-element array. Reverses order if needed.
  void checkReverse(byte[] b) {  
    if (reverseBytes) {
      byte t0 = b[0]; 
      b[0] = b[3]; 
      b[3] = t0;
      byte t1 = b[1]; 
      b[1] = b[2]; 
      b[2] = t1;
    }
  }
  
  // convert an integer to bytes and save in the given buffer
  void intToBytes(int i, byte[] byteBuffer) {
    bb.position(0);    
    b4 = bb.putInt(i).array();
    checkReverse(b4);
    for (int j=0; j<4; j++) byteBuffer[j] = b4[j];
  }
    
  // convert a float to bytes and save in the given buffer
  void floatToBytes(float f, byte[] byteBuffer) {
    bb.position(0);    
    b4 = bb.putFloat(f).array();
    checkReverse(b4);
    for (int j=0; j<4; j++) byteBuffer[j] = b4[j];
  }
  
  // write an integer to the output stream
  void writeInt(int i) { 
    bb.position(0);
    b4 = bb.putInt(i).array();
    checkReverse(b4);
    appendToBuffer(b4);
  } 
  
  // write a buffer of bytes to the output stream
  void writeByteArray(byte[] b) {
    appendToBuffer(b);
  }
  
  // write a float to the output stream
  void writeFloat(float f) {
    bb.position(0);
    b4 = bb.putFloat(f).array(); 
    checkReverse(b4);
    appendToBuffer(b4);
  }
}
