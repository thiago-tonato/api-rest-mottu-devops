package com.mottu.rastreamento.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ManutencaoDTO {

    private Long id;

    @NotNull(message = "A moto é obrigatória.")
    private Long motoId;

    private String descricao;

    private LocalDateTime dataInicio;
    private LocalDateTime dataFim;

    private String status;
}
