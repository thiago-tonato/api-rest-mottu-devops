package com.mottu.rastreamento.repository;

import com.mottu.rastreamento.models.Moto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MotoRepository extends JpaRepository<Moto, Long> {
    Optional<Moto> findByIdentificadorUWB(String identificadorUWB);
    List<Moto> findBySensorId(Long sensorId);
}
