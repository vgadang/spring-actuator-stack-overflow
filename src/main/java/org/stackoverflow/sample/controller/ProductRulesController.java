package org.stackoverflow.sample.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/catalog/products")
public class ProductRulesController {

	@RequestMapping
	public String getProductUpsells() {
		return "ok";
	}
	
}
