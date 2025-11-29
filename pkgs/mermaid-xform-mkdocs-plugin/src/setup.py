from setuptools import setup, find_packages

setup(
    name="mermaidxform-mkdocs-plugin",
    version="2.0.0",
    author="Juan Manuel Piñero Sánchez",
    description="Plugin para MkDocs que transforma bloques Mermaid personalizados en diagramas con estilos y envoltorios HTML automáticos.",
    packages=find_packages(),
    include_package_data=True,
    package_data={
        "mermaidxform_mkdocs_plugin" : ["config-mermaid.json"],
    },
    python_requires=">=3.8",
    install_requires=["mkdocs>=1.5", "mkdocs-material>=9.0"],
    entry_points={
        "mkdocs.plugins": [
            # Este es el nombre que se usa en mkdocs.yml → plugins: [ mermaidxform ]
            "mermaidxform = mermaidxform_mkdocs_plugin.plugin:MermaidXFormMkdocsPlugin",
        ]
    },
)
