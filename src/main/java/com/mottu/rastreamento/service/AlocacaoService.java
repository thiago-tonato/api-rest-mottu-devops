package com.mottu.rastreamento.service;

import com.mottu.rastreamento.dto.AlocacaoDTO;
import com.mottu.rastreamento.models.Alocacao;
import com.mottu.rastreamento.models.Moto;
import com.mottu.rastreamento.models.enums.StatusAlocacao;
import com.mottu.rastreamento.models.enums.StatusMoto;
import com.mottu.rastreamento.repository.AlocacaoRepository;
import com.mottu.rastreamento.repository.MotoRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AlocacaoService {

    private final AlocacaoRepository alocacaoRepository;
    private final MotoRepository motoRepository;

    @Transactional
    public Alocacao abrirAlocacao(AlocacaoDTO dto) {
        Moto moto = motoRepository.findById(dto.getMotoId())
                .orElseThrow(() -> new EntityNotFoundException("Moto não encontrada"));

        if (moto.getStatus() != StatusMoto.DISPONIVEL) {
            throw new IllegalStateException("A moto não está disponível para alocação");
        }

        boolean existeAberta = alocacaoRepository.existsByMotoIdAndFimIsNull(moto.getId());
        if (existeAberta) {
            throw new IllegalStateException("Já existe uma alocação aberta para esta moto");
        }

        Alocacao alocacao = new Alocacao();
        alocacao.setMoto(moto);
        alocacao.setInicio(LocalDateTime.now());
        alocacao.setFim(null);
        alocacao.setStatus(StatusAlocacao.ABERTA);

        moto.setStatus(StatusMoto.ALOCADA);
        motoRepository.save(moto);

        return alocacaoRepository.save(alocacao);
    }

    @Transactional
    public Alocacao encerrarAlocacao(Long id) {
        Alocacao alocacao = alocacaoRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Alocação não encontrada"));

        if (alocacao.getStatus() != StatusAlocacao.ABERTA) {
            throw new IllegalStateException("A alocação já está encerrada");
        }

        alocacao.setFim(LocalDateTime.now());
        alocacao.setStatus(StatusAlocacao.ENCERRADA);

        Moto moto = alocacao.getMoto();
        moto.setStatus(StatusMoto.DISPONIVEL);
        motoRepository.save(moto);

        return alocacaoRepository.save(alocacao);
    }

    public List<Alocacao> listarTodas() {
        return alocacaoRepository.findAll();
    }

    public List<Alocacao> listarAbertas() {
        return alocacaoRepository.findByStatus(StatusAlocacao.ABERTA);
    }
}
