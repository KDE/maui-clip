#pragma once

#include <MauiKit3/Core/fmh.h>
#include <MauiKit3/Core/mauilist.h>

class TagsModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QVariantList quickPlaces READ quickPlaces)

public:
    explicit TagsModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override;
    void componentComplete() override;

    QVariantList quickPlaces() const;

private:
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST tags();

    void packPreviewImages(FMH::MODEL &tag);
    QVariantList m_quickPlaces;
};
