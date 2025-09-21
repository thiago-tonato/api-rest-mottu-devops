package com.mottu.rastreamento.controller.api;

import com.mottu.rastreamento.dto.AlocacaoDTO;
import com.mottu.rastreamento.models.Alocacao;
import com.mottu.rastreamento.service.AlocacaoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/alocacoes")
@RequiredArgsConstructor
public class AlocacaoController {

    private final AlocacaoService alocacaoService;

    @PostMapping("/abrir")
    public ResponseEntity<Alocacao> abrirAlocacao(@RequestBody AlocacaoDTO dto) {
        Alocacao alocacao = alocacaoService.abrirAlocacao(dto);
        return ResponseEntity.ok(alocacao);
    }

    @PostMapping("/encerrar/{id}")
    public ResponseEntity<Alocacao> encerrarAlocacao(@PathVariable Long id) {
        Alocacao alocacao = alocacaoService.encerrarAlocacao(id);
        return ResponseEntity.ok(alocacao);
    }

    @GetMapping
    public ResponseEntity<List<Alocacao>> listarTodas() {
        return ResponseEntity.ok(alocacaoService.listarTodas());
    }

    @GetMapping("/abertas")
    public ResponseEntity<List<Alocacao>> listarAbertas() {
        return ResponseEntity.ok(alocacaoService.listarAbertas());
    }
}
