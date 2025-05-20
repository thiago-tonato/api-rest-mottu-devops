package com.mottu.rastreamento.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "sensores")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SensorUWB {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String localizacao;

    @OneToMany(mappedBy = "sensor", cascade = CascadeType.ALL)
    private List<Moto> motos;
}

