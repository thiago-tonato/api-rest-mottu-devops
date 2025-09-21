package com.mottu.rastreamento.service;

import com.mottu.rastreamento.dto.MotoDTO;
import com.mottu.rastreamento.models.Moto;
import com.mottu.rastreamento.models.SensorUWB;
import com.mottu.rastreamento.repository.MotoRepository;
import com.mottu.rastreamento.repository.SensorUWBRepository;
import org.springframework.cache.annotation.Cacheable;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;


import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MotoService {

    private final MotoRepository motoRepository;
    private final SensorUWBRepository sensorRepository;

    public MotoDTO salvar(MotoDTO dto) {
        Moto moto = new Moto();
        moto.setIdentificadorUWB(dto.getIdentificadorUWB());
        moto.setModelo(dto.getModelo());
        moto.setCor(dto.getCor());

        if (dto.getSensorId() != null) {
            SensorUWB sensor = sensorRepository.findById(dto.getSensorId())
                    .orElseThrow(() -> new EntityNotFoundException("Sensor não encontrado"));
            moto.setSensor(sensor);
        }

        moto.setStatus(com.mottu.rastreamento.models.enums.StatusMoto.DISPONIVEL);

        return toDTO(motoRepository.save(moto));
    }

    public Page<MotoDTO> listar(Pageable pageable) {
        return motoRepository.findAll(pageable)
                .map(this::toDTO);
    }

    public List<MotoDTO> listarTodas() {
        return motoRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<MotoDTO> listarTodasDisponiveis() {
        return motoRepository.findAll().stream()
                .filter(m -> m.getStatus() == com.mottu.rastreamento.models.enums.StatusMoto.DISPONIVEL)
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public MotoDTO buscarPorId(Long id) {
        Moto moto = motoRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Moto não encontrada"));
        return toDTO(moto);
    }

    @Cacheable(value = "motos", key = "#identificadorUWB")
    public MotoDTO buscarPorIdentificadorUWB(String identificadorUWB) {
        System.out.println("🔍 Consultando banco para identificadorUWB: " + identificadorUWB);
        Moto moto = motoRepository.findByIdentificadorUWB(identificadorUWB)
                .orElseThrow(() -> new EntityNotFoundException("Moto com UWB '" + identificadorUWB + "' não encontrada"));
        return toDTO(moto);
    }

    public MotoDTO atualizar(Long id, MotoDTO dto) {
        Moto moto = motoRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Moto não encontrada"));

        moto.setIdentificadorUWB(dto.getIdentificadorUWB());
        moto.setModelo(dto.getModelo());
        moto.setCor(dto.getCor());

        if (dto.getSensorId() != null) {
            SensorUWB sensor = sensorRepository.findById(dto.getSensorId())
                    .orElseThrow(() -> new EntityNotFoundException("Sensor não encontrado"));
            moto.setSensor(sensor);
        }

        return toDTO(motoRepository.save(moto));
    }

    public void deletar(Long id) {
        Moto moto = motoRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Moto não encontrada"));
        motoRepository.delete(moto);
    }

    private MotoDTO toDTO(Moto moto) {
        MotoDTO dto = new MotoDTO();
        dto.setId(moto.getId());
        dto.setModelo(moto.getModelo());
        dto.setCor(moto.getCor());
        dto.setIdentificadorUWB(moto.getIdentificadorUWB());
        if (moto.getSensor() != null) {
            dto.setSensorId(moto.getSensor().getId());
        }
        return dto;
    }
}

