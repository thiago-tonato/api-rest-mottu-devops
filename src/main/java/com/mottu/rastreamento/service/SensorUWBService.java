package com.mottu.rastreamento.service;

import com.mottu.rastreamento.dto.SensorDTO;
import com.mottu.rastreamento.models.SensorUWB;
import com.mottu.rastreamento.repository.SensorUWBRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SensorUWBService {

    private final SensorUWBRepository repository;

    public SensorDTO salvar(SensorDTO dto) {
        SensorUWB sensor = new SensorUWB();
        sensor.setLocalizacao(dto.getLocalizacao());
        return toDTO(repository.save(sensor));
    }

    public Page<SensorDTO> listar(Pageable pageable) {
        return repository.findAll(pageable)
                .map(this::toDTO);
    }

    public List<SensorDTO> listarTodos() {
        return repository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public SensorDTO buscarPorId(Long id) {
        SensorUWB sensor = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Sensor não encontrado"));
        return toDTO(sensor);
    }

    public SensorDTO atualizar(Long id, SensorDTO dto) {
        SensorUWB sensor = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Sensor não encontrado"));
        sensor.setLocalizacao(dto.getLocalizacao());
        return toDTO(repository.save(sensor));
    }

    public void deletar(Long id) {
        SensorUWB sensor = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Sensor não encontrado"));
        repository.delete(sensor);
    }

    private SensorDTO toDTO(SensorUWB sensor) {
        SensorDTO dto = new SensorDTO();
        dto.setId(sensor.getId());
        dto.setLocalizacao(sensor.getLocalizacao());
        return dto;
    }
}
