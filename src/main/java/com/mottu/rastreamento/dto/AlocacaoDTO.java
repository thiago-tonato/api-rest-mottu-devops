package com.mottu.rastreamento.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AlocacaoDTO {

    private Long id;

    @NotNull(message = "A moto é obrigatória.")
    private Long motoId;

    private LocalDateTime inicio;
    private LocalDateTime fim;

    private String status;
}
