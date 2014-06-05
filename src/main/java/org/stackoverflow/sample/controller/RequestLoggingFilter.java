package org.stackoverflow.sample.controller;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.aol.logging.filter.LoggingRequestWrapper;
import com.aol.logging.filter.LoggingResponseWrapper;


/**
 * @author Vikram.Gadang
 */
public class RequestLoggingFilter implements Filter {

	
	public void init(final FilterConfig config) throws ServletException {
    	// Empty method
    }

    public void destroy() {
    	// Empty method
    }

	public void doFilter(final ServletRequest req, final ServletResponse resp, final FilterChain chain) throws ServletException, IOException {
    	final LoggingRequestWrapper requestWrapper = new LoggingRequestWrapper((HttpServletRequest) req);
        final LoggingResponseWrapper responseWrapper = new LoggingResponseWrapper((HttpServletResponse) resp); 


		// Proceed with the filter Chain
        chain.doFilter(requestWrapper, responseWrapper);
        
    }
    
}
