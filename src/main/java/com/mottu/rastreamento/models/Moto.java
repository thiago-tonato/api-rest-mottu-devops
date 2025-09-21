package com.mottu.rastreamento.models;

import com.mottu.rastreamento.models.enums.StatusMoto;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
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
    @Column(name = "identificador_uwb", nullable = false, unique = true)
    private String identificadorUWB;

    @NotBlank
    private String modelo;

    @NotBlank
    private String cor;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusMoto status = StatusMoto.DISPONIVEL; // default

    @ManyToOne
    @JoinColumn(name = "sensor_id")
    private SensorUWB sensor;
}
