package com.mottu.rastreamento.controller.view;

import com.mottu.rastreamento.dto.MotoDTO;
import com.mottu.rastreamento.service.MotoService;
import com.mottu.rastreamento.service.SensorUWBService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/motos")
@RequiredArgsConstructor
public class MotoViewController {

    private final MotoService service;
    private final SensorUWBService sensorService;

    @GetMapping
    public String listar(Model model, @ModelAttribute("successMessage") String successMessage) {
        Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 20);
        model.addAttribute("motos", service.listar(pageable).getContent());

        if (successMessage != null && !successMessage.isEmpty()) {
            model.addAttribute("successMessage", successMessage);
        }

        return "motos/list";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("moto", new MotoDTO());
        model.addAttribute("sensores", sensorService.listarTodos());
        return "motos/form";
    }

    @PostMapping
    public String salvar(@Valid @ModelAttribute("moto") MotoDTO dto, RedirectAttributes redirectAttributes) {
        service.salvar(dto);
        redirectAttributes.addFlashAttribute("successMessage", "Moto cadastrada com sucesso!");
        return "redirect:/motos";
    }

    @GetMapping("/editar/{id}")
    public String editarForm(@PathVariable Long id, Model model) {
        model.addAttribute("moto", service.buscarPorId(id));
        model.addAttribute("sensores", sensorService.listarTodos());
        return "motos/form";
    }

    @PostMapping("/editar/{id}")
    public String atualizar(@PathVariable Long id, @Valid @ModelAttribute("moto") MotoDTO dto, RedirectAttributes redirectAttributes) {
        service.atualizar(id, dto);
        redirectAttributes.addFlashAttribute("successMessage", "Moto atualizada com sucesso!");
        return "redirect:/motos";
    }

    @GetMapping("/deletar/{id}")
    public String deletar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        service.deletar(id);
        redirectAttributes.addFlashAttribute("successMessage", "Moto removida com sucesso!");
        return "redirect:/motos";
    }
}
