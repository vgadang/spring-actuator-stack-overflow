package com.aol.logging.filter;

import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletOutputStream;

import org.apache.commons.io.output.TeeOutputStream;

public class TeeServletOutputStream extends ServletOutputStream {

	private final TeeOutputStream target;

	public TeeServletOutputStream(OutputStream outOne, OutputStream outTwo) {
		target = new TeeOutputStream(outOne, outTwo);
	}

	@Override
	public void write(int b) throws IOException {
		target.write(b);
	}

	@Override
	public void close() throws IOException {
		target.close();
	}

	@Override
	public void flush() throws IOException {
		target.flush();
	}

	@Override
	public void write(byte[] b, int off, int len) throws IOException {
		target.write(b, off, len);
	}

	@Override
	public void write(byte[] b) throws IOException {
		target.write(b);
	}

}
