package com.mottu.rastreamento.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Entity
@Table(name = "motos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Moto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String identificadorUWB;

    @NotBlank
    private String modelo;

    @NotBlank
    private String cor;

    @ManyToOne
    @JoinColumn(name = "sensor_id")
    private SensorUWB sensor;
}
