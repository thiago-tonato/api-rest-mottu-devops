package com.mottu.rastreamento.repository;

import com.mottu.rastreamento.models.Manutencao;
import com.mottu.rastreamento.models.enums.StatusManutencao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ManutencaoRepository extends JpaRepository<Manutencao, Long> {
    boolean existsByMotoIdAndStatus(Long motoId, StatusManutencao status);
    List<Manutencao> findByStatus(StatusManutencao status);
}
