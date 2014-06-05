package com.aol.logging.filter;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

public class LoggingResponseWrapper extends HttpServletResponseWrapper {

	private ByteArrayOutputStream baOut;

	public LoggingResponseWrapper(HttpServletResponse response)
			throws IOException {
		super(response);
		baOut = new ByteArrayOutputStream();
	}

	@Override
	public ServletOutputStream getOutputStream() throws IOException {
		return new TeeServletOutputStream(super.getOutputStream(), baOut);
	}

	@Override
	public PrintWriter getWriter() throws IOException {
		return new TeeWriter(super.getWriter(), new PrintWriter(baOut, true));
	}

	// Captures the response body
	public String getBody() {
		return baOut.toString();
	}

}
