package com.example.sprintbootdemo.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;



@RestController
@RequestMapping(value= "/hello", produces = "text/plain")
public class HelloWorldController {

    Logger logger = LoggerFactory.getLogger(getClass());

    @GetMapping(value = "")
    public String get() {
        logger.info("print hello world!");
        return "Hello World!";
    }
}