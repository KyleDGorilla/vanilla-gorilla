# Vanilla Gorilla - WoW 3.3.5a Private Server Project

> **Educational Portfolio Project**: This project demonstrates DevOps, cloud architecture, and game systems design skills for professional portfolio purposes. Not intended for commercial use.

## Project Overview

Vanilla Gorilla is a custom World of Warcraft 3.3.5a private server showcasing hybrid cloud architecture, custom content development, and comprehensive technical documentation practices. This project serves as a case study in Solutions Architecture, demonstrating skills in:

- Hybrid cloud infrastructure design (AWS + on-premises)
- Database architecture and optimization
- Custom application development (Python launcher with CI/CD)
- Game world architecture documentation and modification
- DevOps practices and automation

## Architecture

**Hybrid Cloud Design:**
- **Authserver**: AWS EC2 (t2.micro) with Lambda-based scheduling
- **Worldserver**: Windows mini PC (local)
- **Content Distribution**: AWS S3 + CloudFlare CDN
- **DNS Management**: CloudFlare with automated AWS integration

Full architecture documentation: [Architecture Portfolio](https://github.com/KyleDGorilla/architecture-portfolio/tree/main/projects/mmorpg-aws)

## Project Components

### Custom Game Launcher
Python-based launcher with:
- Automated client distribution from AWS S3
- Patch management and version control
- CustomTkinter UI for user-friendly experience
- Integration with game client launch

📁 **Code**: [`/launcher`](./launcher)

### World Architecture Documentation
Systematic documentation of game world architecture using arc42 methodology, demonstrating legacy system analysis and technical documentation skills.

📁 **Documentation**: [`/docs/architecture/zones`](./docs/architecture/zones)

### Server Configurations
Template configurations for AzerothCore deployment (sensitive values removed).

📁 **Configs**: [`/server-configs`](./server-configs)

## Documentation

This project emphasizes documentation-as-code practices:

- **Architecture Decision Records (ADRs)**: Key technical decisions with rationale
- **Zone Architecture Documentation**: Reverse-engineered game world analysis
- **Implementation Guides**: Step-by-step technical documentation
- **Diagrams**: System architecture visualizations

## Related Work

- **[Architecture Portfolio](https://github.com/KyleDGorilla/architecture-portfolio)**: High-level case studies and professional summaries
- **[MMORPG AWS Infrastructure Case Study](https://github.com/KyleDGorilla/architecture-portfolio/tree/main/projects/mmorpg-aws)**: Infrastructure design documentation
- **[World Architecture Documentation](https://github.com/KyleDGorilla/architecture-portfolio/tree/main/projects/world-architecture-documentation)**: Game world analysis methodology

## Skills Demonstrated

### Cloud & Infrastructure
- AWS services (EC2, S3, Route53, Lambda, EventBridge)
- Hybrid cloud architecture design
- Cost optimization strategies
- Infrastructure automation

### Development
- Python application development
- UI/UX design with CustomTkinter
- CI/CD pipeline implementation
- Version control and Git workflows

### Architecture & Documentation
- arc42 documentation framework
- Architecture Decision Records (ADRs)
- Technical writing for mixed audiences
- System analysis and reverse engineering

### Database & Systems
- MySQL/MariaDB optimization
- Schema design and analysis
- Legacy system documentation
- Performance profiling

## Technology Stack

- **Core Server**: AzerothCore (WoW 3.3.5a emulator)
- **Cloud**: AWS (EC2, S3, Lambda, Route53)
- **CDN**: CloudFlare
- **Development**: Python 3.12+, CustomTkinter
- **Database**: MySQL/MariaDB
- **World Editing**: NoggIt
- **Documentation**: Markdown, Mermaid diagrams
- **Version Control**: Git, GitHub

## Project Status

🟢 **Active Development** - Ongoing documentation and custom content creation

Current focus areas:
- StrangleThorn Vale architecture documentation
- Port Gurubashi contested city design
- Bot AI enhancement
- Performance optimization

## Educational Purpose & Legal Notice

This project is created and maintained for **educational and portfolio demonstration purposes only**. It showcases technical skills in software architecture, cloud infrastructure, and system design.

**Legal Considerations:**
- World of Warcraft® is a registered trademark of Blizzard Entertainment
- This project uses AzerothCore, an open-source game server emulator
- No game client files, assets, or proprietary code are distributed
- No commercial services are offered
- Project demonstrates technical skills only

**Fair Use Statement:** This project constitutes fair use for educational purposes, demonstrating software architecture, cloud computing, and technical documentation skills without commercial intent.

## Contact

**Kyle Dahgon**  
Solutions Architect  
[GitHub](https://github.com/KyleDGorilla) | [Architecture Portfolio](https://github.com/KyleDGorilla/architecture-portfolio)

For questions about the architecture, implementation, or technical decisions, please open an issue or reach out via GitHub.

## License

Documentation and custom code in this repository are available under MIT License for educational use.

Game server components (AzerothCore) are licensed under GNU AGPL v3.0.

World of Warcraft® content is property of Blizzard Entertainment and not included in this repository.

---

*This is a portfolio project demonstrating Solutions Architecture skills. Last updated: January 2026*# vanilla-gorilla
technical repo for all Vanilla Gorilla work
