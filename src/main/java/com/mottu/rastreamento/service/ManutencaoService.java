package com.mottu.rastreamento.service;

import com.mottu.rastreamento.dto.ManutencaoDTO;
import com.mottu.rastreamento.models.Manutencao;
import com.mottu.rastreamento.models.Moto;
import com.mottu.rastreamento.models.enums.StatusManutencao;
import com.mottu.rastreamento.models.enums.StatusMoto;
import com.mottu.rastreamento.repository.ManutencaoRepository;
import com.mottu.rastreamento.repository.MotoRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ManutencaoService {

    private final ManutencaoRepository manutencaoRepository;
    private final MotoRepository motoRepository;

    @Transactional
    public Manutencao abrirManutencao(ManutencaoDTO dto) {
        Moto moto = motoRepository.findById(dto.getMotoId())
                .orElseThrow(() -> new EntityNotFoundException("Moto não encontrada"));

        if (moto.getStatus() != StatusMoto.DISPONIVEL) {
            throw new IllegalStateException("A moto não está disponível para manutenção");
        }

        boolean existeAberta = manutencaoRepository.existsByMotoIdAndStatus(moto.getId(), StatusManutencao.ABERTA);
        if (existeAberta) {
            throw new IllegalStateException("Já existe uma manutenção aberta para esta moto");
        }

        Manutencao manutencao = new Manutencao();
        manutencao.setMoto(moto);
        manutencao.setDescricao(dto.getDescricao());
        manutencao.setDataInicio(LocalDateTime.now());
        manutencao.setStatus(StatusManutencao.ABERTA);

        moto.setStatus(StatusMoto.MANUTENCAO);
        motoRepository.save(moto);

        return manutencaoRepository.save(manutencao);
    }

    @Transactional
    public Manutencao encerrarManutencao(Long id) {
        Manutencao manutencao = manutencaoRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Manutenção não encontrada"));

        if (manutencao.getStatus() != StatusManutencao.ABERTA) {
            throw new IllegalStateException("A manutenção já está encerrada");
        }

        manutencao.setDataFim(LocalDateTime.now());
        manutencao.setStatus(StatusManutencao.ENCERRADA);

        Moto moto = manutencao.getMoto();
        moto.setStatus(StatusMoto.DISPONIVEL);
        motoRepository.save(moto);

        return manutencaoRepository.save(manutencao);
    }

    public List<Manutencao> listarTodas() {
        return manutencaoRepository.findAll();
    }

    public List<Manutencao> listarAbertas() {
        return manutencaoRepository.findByStatus(StatusManutencao.ABERTA);
    }
}
