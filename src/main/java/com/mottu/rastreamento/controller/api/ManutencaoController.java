package com.mottu.rastreamento.controller.api;

import com.mottu.rastreamento.dto.ManutencaoDTO;
import com.mottu.rastreamento.models.Manutencao;
import com.mottu.rastreamento.service.ManutencaoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/manutencoes")
@RequiredArgsConstructor
public class ManutencaoController {

    private final ManutencaoService manutencaoService;

    @PostMapping
    public Manutencao abrir(@Valid @RequestBody ManutencaoDTO dto) {
        return manutencaoService.abrirManutencao(dto);
    }

    @PutMapping("/{id}/encerrar")
    public Manutencao encerrar(@PathVariable Long id) {
        return manutencaoService.encerrarManutencao(id);
    }

    @GetMapping
    public List<Manutencao> listarTodas() {
        return manutencaoService.listarTodas();
    }

    @GetMapping("/abertas")
    public List<Manutencao> listarAbertas() {
        return manutencaoService.listarAbertas();
    }
}
