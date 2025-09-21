package com.mottu.rastreamento.controller.view;

import com.mottu.rastreamento.dto.SensorDTO;
import com.mottu.rastreamento.service.SensorUWBService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/sensores")
@RequiredArgsConstructor
public class SensorViewController {

    private final SensorUWBService service;

    @GetMapping
    public String listar(Model model, @ModelAttribute("successMessage") String successMessage) {
        Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 20);
        model.addAttribute("sensores", service.listar(pageable).getContent());

        if (successMessage != null && !successMessage.isEmpty()) {
            model.addAttribute("successMessage", successMessage);
        }

        return "sensores/list";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("sensor", new SensorDTO());
        return "sensores/form";
    }

    @PostMapping
    public String salvar(@Valid @ModelAttribute("sensor") SensorDTO dto, RedirectAttributes redirectAttributes) {
        service.salvar(dto);
        redirectAttributes.addFlashAttribute("successMessage", "Sensor cadastrado com sucesso!");
        return "redirect:/sensores";
    }

    @GetMapping("/editar/{id}")
    public String editarForm(@PathVariable Long id, Model model) {
        model.addAttribute("sensor", service.buscarPorId(id));
        return "sensores/form";
    }

    @PostMapping("/editar/{id}")
    public String atualizar(@PathVariable Long id, @Valid @ModelAttribute("sensor") SensorDTO dto, RedirectAttributes redirectAttributes) {
        service.atualizar(id, dto);
        redirectAttributes.addFlashAttribute("successMessage", "Sensor atualizado com sucesso!");
        return "redirect:/sensores";
    }

    @GetMapping("/deletar/{id}")
    public String deletar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        service.deletar(id);
        redirectAttributes.addFlashAttribute("successMessage", "Sensor removido com sucesso!");
        return "redirect:/sensores";
    }
}
