package com.mottu.rastreamento.repository;

import com.mottu.rastreamento.models.Alocacao;
import com.mottu.rastreamento.models.enums.StatusAlocacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlocacaoRepository extends JpaRepository<Alocacao, Long> {
    boolean existsByMotoIdAndFimIsNull(Long motoId);
    List<Alocacao> findByStatus(StatusAlocacao status);
}
