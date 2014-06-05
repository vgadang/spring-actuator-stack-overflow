package org.stackoverflow.sample.application;

import javax.servlet.Filter;
import javax.servlet.ServletRequestListener;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextListener;
import org.stackoverflow.sample.filter.RequestLoggingFilter;

@Configuration
public class LogsConfiguration {

	@Bean
	public ServletRequestListener requestListener() {
		return new RequestContextListener();
	}
	
    @Bean
    public Filter loggingFilter() throws Exception {
    	return new RequestLoggingFilter();
    }

}