package com.mottu.rastreamento.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MotoDTO {
    @NotBlank(message = "Modelo é obrigatório")
    private String modelo;

    @NotBlank(message = "Cor é obrigatória")
    private String cor;

    @NotBlank(message = "Identificador UWB é obrigatório")
    private String identificadorUWB;

    @NotNull(message = "SensorId é obrigatório")
    private Long sensorId;

    private Long id;
}
