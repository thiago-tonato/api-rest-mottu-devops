package com.mottu.rastreamento;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class RastreamentoApplication {
	public static void main(String[] args) {
		SpringApplication.run(RastreamentoApplication.class, args);
	}
}
