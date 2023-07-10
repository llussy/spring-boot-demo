package com.example.sprintbootdemo.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping(value= "/hello", produces = "text/plain")
public class HelloWorldController {

    @GetMapping(value = "")
    public String get() {
        return "Hello World!";
    }
}